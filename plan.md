
# Twift pro Banking Website - Project Plan

## Overview
This document outlines the plan to build a new banking website named "Twift pro". The website will offer user account creation with email verification, profile management, a secure withdrawal system, an admin panel for fund management, and transaction history logging.

## Core Features:

1.  **User Account Management**:
    *   **Sign-up**: Users can create accounts using their email and a password.
    *   **Email Verification**: A verification code will be sent to the user's email upon registration. The account will be active only after successful verification.
    *   **Login**: Registered and verified users can log in.

2.  **User Profile & Account Details**:
    *   Each user will be assigned a unique account number upon successful verification.
    *   The user's profile page will display their account number and current balance.
    *   **Initial Balance**: All new accounts will start with 0.00 USD.

3.  **Withdrawal System**:
    *   Users can initiate withdrawals to their local bank accounts.
    *   A "transaction key" will be required during the withdrawal process.
    *   **Security Feature**: Any transaction key provided by the user will be flagged as invalid, preventing unauthorized or accidental withdrawals to external accounts through this specific mechanism.

4.  **Admin Panel & Fund Management**:
    *   A dedicated interface for the website owner (admin) to manage user accounts.
    *   **Admin Deposit**: The admin will be able to deposit any specified amount into any user's account using their account number.

5.  **Transaction History**:
    *   A chronological log of all financial transactions for each user.
    *   **Credit Transactions**: Specifically, credit transactions resulting from admin deposits will be clearly recorded and visible to the user.

## Implementation Strategy:

This project will be developed using a combination of frontend and backend services.

*   **Frontend (Agent: frontend_engineer)**:
    *   Will be responsible for all User Interface (UI) and User Experience (UX) components.
    *   This includes: Sign-up forms, login screens, email verification interfaces, user dashboard/profile pages, withdrawal forms, transaction history views, and the admin panel interface.
    *   **Mandatory First Step**: The `frontend_engineer` must execute the `generate_images_bulk` tool before writing any code files.

*   **Backend (Agent: supabase_engineer)**:
    *   Will handle all server-side logic, database management, and API endpoints.
    *   **Database**: Design and implement the database schema using Supabase for:
        *   `users` table (for authentication details).
        *   `accounts` table (storing account numbers, user IDs, balances).
        *   `transactions` table (logging transaction details: type, amount, timestamp, related account/user).
    *   **Authentication & Verification**: Implement Supabase Auth for user registration, login, and email verification flows.
    *   **Account Number Generation**: Develop a robust mechanism for generating unique account numbers.
    *   **Business Logic**: Implement the core banking logic:
        *   Admin deposit functionality (updating balances and logging transactions).
        *   Withdrawal processing, including the "invalid key" constraint.
    *   **Edge Functions**: Utilize Supabase Edge Functions if complex server-side logic or external API integrations are required.

## Workflow:

1.  **Initial Setup**:
    *   **Architect**: Execute `preflight_check` to assess the current sandbox environment.
    *   **Architect**: Execute `create_plan` with this content to establish the project's roadmap.

2.  **Development Phase**:
    *   **Architect**: Transfer core UI/UX tasks to the `frontend_engineer`. This agent will start by running `generate_images_bulk` and then proceed with building the frontend components.
    *   **Architect**: Transfer backend infrastructure and logic tasks to the `supabase_engineer`. This agent will set up the database, authentication, and implement the required business logic.

3.  **Integration & Validation**:
    *   Frontend and backend components will be integrated.
    *   **Architect**: Once development is deemed complete by the respective agents, the `Architect` will call `validate_build` to verify the entire implementation. If validation fails, the `Architect` will coordinate with the agents to fix the issues and re-validate.

This plan ensures all user requirements are addressed systematically, leveraging the strengths of the specialized agents.
