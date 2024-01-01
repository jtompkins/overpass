-- supabase/seed.sql
--
-- create test users
INSERT INTO auth.users (
        instance_id,
        id,
        aud,
        role,
        email,
        encrypted_password,
        email_confirmed_at,
        recovery_sent_at,
        last_sign_in_at,
        raw_app_meta_data,
        raw_user_meta_data,
        created_at,
        updated_at,
        confirmation_token,
        email_change,
        email_change_token_new,
        recovery_token
    ) (
        SELECT '00000000-0000-0000-0000-000000000000',
            uuid_generate_v4 (),
            'authenticated',
            'authenticated',
            'user' || (ROW_NUMBER() OVER ()) || '@example.com',
            crypt ('password123', gen_salt ('bf')),
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            '{"provider":"email","providers":["email"]}',
            '{}',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            '',
            '',
            '',
            ''
        FROM generate_series(1, 5)
    );

-- test user email identities
INSERT INTO auth.identities (
        id,
        user_id,
        provider_id,
        identity_data,
        provider,
        last_sign_in_at,
        created_at,
        updated_at
    ) (
        SELECT uuid_generate_v4 (),
            id,
            id,
            format('{"sub":"%s","email":"%s"}', id::text, email)::jsonb,
            'email',
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP,
            CURRENT_TIMESTAMP
        FROM auth.users
    );

-- create some friendly profiles for each of the test users
INSERT INTO profiles (
        id,
        updated_at,
        display_name,
        avatar_url,
        following_count,
        follower_count,
        public
    )
SELECT id,
    NOW(),
    'Test User 1',
    'www.test.com',
    0,
    0,
    TRUE
FROM auth.users
WHERE email = 'user1@example.com';

INSERT INTO profiles (
        id,
        updated_at,
        display_name,
        avatar_url,
        following_count,
        follower_count,
        public
    )
SELECT id,
    NOW(),
    'Test User 2',
    'www.test.com',
    0,
    0,
    TRUE
FROM auth.users
WHERE email = 'user2@example.com';

INSERT INTO profiles (
        id,
        updated_at,
        display_name,
        avatar_url,
        following_count,
        follower_count,
        public
    )
SELECT id,
    NOW(),
    'Test User 3',
    'www.test.com',
    0,
    0,
    TRUE
FROM auth.users
WHERE email = 'user3@example.com';

INSERT INTO profiles (
        id,
        updated_at,
        display_name,
        avatar_url,
        following_count,
        follower_count,
        public
    )
SELECT id,
    NOW(),
    'Test User 4',
    'www.test.com',
    0,
    0,
    TRUE
FROM auth.users
WHERE email = 'user4@example.com';

INSERT INTO profiles (
        id,
        updated_at,
        display_name,
        avatar_url,
        following_count,
        follower_count,
        public
    )
SELECT id,
    NOW(),
    'Test User 5',
    'www.test.com',
    0,
    0,
    TRUE
FROM auth.users
WHERE email = 'user5@example.com';

-- create test URL entries
INSERT INTO urls (url, title)
VALUES ('http://www.google.com', 'Test URL 1');

INSERT INTO urls (url, title)
VALUES ('http://www.google.com', 'Test URL 2');

INSERT INTO urls (url, title)
VALUES ('http://www.google.com', 'Test URL 3');

INSERT INTO urls (url, title)
VALUES ('http://www.google.com', 'Test URL 4');

INSERT INTO urls (url, title)
VALUES ('http://www.google.com', 'Test URL 5');

-- create test posts, associated with each of the test users
INSERT INTO posts (user_id, url_id, public)
SELECT id,
    1,
    TRUE
FROM auth.users
WHERE email = 'user1@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    2,
    false
FROM auth.users
WHERE email = 'user1@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    3,
    false
FROM auth.users
WHERE email = 'user1@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    4,
    TRUE
FROM auth.users
WHERE email = 'user2@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    5,
    TRUE
FROM auth.users
WHERE email = 'user2@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    3,
    TRUE
FROM auth.users
WHERE email = 'user3@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    4,
    TRUE
FROM auth.users
WHERE email = 'user3@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    5,
    false
FROM auth.users
WHERE email = 'user3@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    1,
    TRUE
FROM auth.users
WHERE email = 'user4@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    2,
    TRUE
FROM auth.users
WHERE email = 'user4@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    3,
    false
FROM auth.users
WHERE email = 'user4@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    4,
    false
FROM auth.users
WHERE email = 'user4@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    5,
    TRUE
FROM auth.users
WHERE email = 'user4@example.com';

INSERT INTO posts (user_id, url_id, public)
SELECT id,
    1,
    false
FROM auth.users
WHERE email = 'user5@example.com';
