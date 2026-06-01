
CREATE TABLE IF NOT EXISTS users (
    id            SERIAL PRIMARY KEY,
    username      VARCHAR(255) UNIQUE NOT NULL,
    password      VARCHAR(255) NOT NULL,
    email         VARCHAR(255) UNIQUE,
    role          VARCHAR(20)  NOT NULL DEFAULT 'USER',
    profile_image VARCHAR(255),
    is_online     BOOLEAN      NOT NULL DEFAULT FALSE,
    is_blocked    BOOLEAN      NOT NULL DEFAULT FALSE,
    last_seen     TIMESTAMP,
    blocked_until TIMESTAMP,
    created_at    TIMESTAMP    NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS contacts (
    id         SERIAL PRIMARY KEY,
    user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    contact_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    UNIQUE (user_id, contact_id)
);

CREATE TABLE IF NOT EXISTS chats (
    id         SERIAL PRIMARY KEY,
    name       VARCHAR(255),
    is_group   BOOLEAN NOT NULL DEFAULT FALSE,
    created_by INTEGER REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS chat_participants (
    id      SERIAL PRIMARY KEY,
    chat_id INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE (chat_id, user_id)
);

CREATE TABLE IF NOT EXISTS messages (
    id         SERIAL PRIMARY KEY,
    chat_id    INTEGER NOT NULL REFERENCES chats(id) ON DELETE CASCADE,
    sender_id  INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    content    TEXT,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    has_file   BOOLEAN NOT NULL DEFAULT FALSE,
    file_name  VARCHAR(255),
    file_type  VARCHAR(100),
    file_url   VARCHAR(512),
    file_size  BIGINT,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS reports (
    id             SERIAL PRIMARY KEY,
    message_id     INTEGER NOT NULL REFERENCES messages(id) ON DELETE CASCADE,
    reporter_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    reason         TEXT,
    status         VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    admin_decision TEXT,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS friend_requests (
    id           SERIAL PRIMARY KEY,
    from_user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    to_user_id   INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status       VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    created_at   TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS admin_logs (
    id             SERIAL PRIMARY KEY,
    admin_id       INTEGER REFERENCES users(id) ON DELETE SET NULL,
    target_user_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
    action         VARCHAR(50),
    reason         TEXT,
    details        TEXT,
    created_at     TIMESTAMP NOT NULL DEFAULT NOW()
);

-- администратор по умолчанию
INSERT INTO users (username, password, email, role)
VALUES ('admin', 'admin', 'admin@example.com', 'ADMIN')
ON CONFLICT (username) DO NOTHING;
