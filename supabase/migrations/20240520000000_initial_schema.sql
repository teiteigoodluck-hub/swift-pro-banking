-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID REFERENCES auth.users ON DELETE CASCADE PRIMARY KEY,
    full_name TEXT,
    account_number TEXT UNIQUE,
    balance DECIMAL(12, 2) DEFAULT 0.00 NOT NULL,
    is_admin BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Create transactions table
CREATE TABLE IF NOT EXISTS public.transactions (
    id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
    profile_id UUID REFERENCES public.profiles(id) ON DELETE CASCADE NOT NULL,
    amount DECIMAL(12, 2) NOT NULL,
    type TEXT CHECK (type IN ('credit', 'debit')) NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Enable RLS
ALTER TABLE public.transactions ENABLE ROW LEVEL SECURITY;

-- Function to generate a random 10-digit account number
CREATE OR REPLACE FUNCTION generate_account_number()
RETURNS TEXT AS $$
DECLARE
    new_acc TEXT;
    done BOOL DEFAULT FALSE;
BEGIN
    WHILE NOT done LOOP
        new_acc := floor(random() * 9000000000 + 1000000000)::TEXT;
        SELECT NOT EXISTS (SELECT 1 FROM public.profiles WHERE account_number = new_acc) INTO done;
    END LOOP;
    RETURN new_acc;
END;
$$ LANGUAGE plpgsql;

-- Trigger to create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, full_name, account_number, balance)
    VALUES (
        new.id,
        new.raw_user_meta_data->>'full_name',
        generate_account_number(),
        0.00
    );
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- RLS Policies for Profiles
CREATE POLICY "Users can view their own profile"
    ON public.profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles"
    ON public.profiles FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_admin = TRUE
        )
    );

CREATE POLICY "Admins can update balances"
    ON public.profiles FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_admin = TRUE
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_admin = TRUE
        )
    );

-- RLS Policies for Transactions
CREATE POLICY "Users can view their own transactions"
    ON public.transactions FOR SELECT
    USING (auth.uid() = profile_id);

CREATE POLICY "Admins can view all transactions"
    ON public.transactions FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_admin = TRUE
        )
    );

CREATE POLICY "Admins can insert transactions"
    ON public.transactions FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.profiles
            WHERE id = auth.uid() AND is_admin = TRUE
        )
    );

-- Function for Admin to credit account by account number
CREATE OR REPLACE FUNCTION credit_account_by_number(target_account_number TEXT, credit_amount DECIMAL(12, 2), credit_description TEXT)
RETURNS VOID AS $$
DECLARE
    target_profile_id UUID;
BEGIN
    -- Verify if caller is admin
    IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND is_admin = TRUE) THEN
        RAISE EXCEPTION 'Unauthorized: Only admins can credit accounts.';
    END IF;

    -- Get target profile id
    SELECT id INTO target_profile_id FROM public.profiles WHERE account_number = target_account_number;

    IF target_profile_id IS NULL THEN
        RAISE EXCEPTION 'Account number % not found.', target_account_number;
    END IF;

    -- Update balance
    UPDATE public.profiles
    SET balance = balance + credit_amount,
        updated_at = now()
    WHERE id = target_profile_id;

    -- Record transaction
    INSERT INTO public.transactions (profile_id, amount, type, description)
    VALUES (target_profile_id, credit_amount, 'credit', credit_description);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;