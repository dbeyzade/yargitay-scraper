-- Avukat Portal - Supabase Database Schema
-- Bu SQL dosyasını Supabase SQL Editor'da çalıştırın

-- Müvekkiller tablosu
CREATE TABLE clients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    tc_no VARCHAR(11) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    photo_url TEXT,
    phone_number VARCHAR(20) NOT NULL,
    address TEXT NOT NULL,
    vasi_name VARCHAR(200),
    vasi_phone VARCHAR(20),
    agreed_amount DECIMAL(15, 2) DEFAULT 0,
    paid_amount DECIMAL(15, 2) DEFAULT 0,
    debt DECIMAL(15, 2) DEFAULT 0,
    notes TEXT,
    birth_date VARCHAR(50),
    birth_place VARCHAR(100),
    mother_name VARCHAR(100),
    father_name VARCHAR(100),
    id_serial_no VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

-- Ödemeler tablosu
CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    amount DECIMAL(15, 2) NOT NULL,
    payment_date TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    description TEXT,
    payment_type VARCHAR(50) DEFAULT 'payment', -- 'payment', 'expense', 'court_fee', 'file_expense'
    is_income BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Ödeme taahhütleri tablosu
CREATE TABLE payment_commitments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    amount DECIMAL(15, 2) NOT NULL,
    commitment_date TIMESTAMP WITH TIME ZONE NOT NULL,
    is_completed BOOLEAN DEFAULT false,
    has_alarm BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Mahkeme tarihleri tablosu
CREATE TABLE court_dates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    court_date TIMESTAMP WITH TIME ZONE NOT NULL,
    court_name VARCHAR(200) NOT NULL,
    case_number VARCHAR(100) NOT NULL,
    notes TEXT,
    reminder_one_day_before BOOLEAN DEFAULT true,
    reminder_on_day BOOLEAN DEFAULT true,
    is_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Belgeler tablosu
CREATE TABLE client_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    document_type VARCHAR(50) DEFAULT 'other', -- 'reasoned_decision', 'request', 'other'
    category_id UUID,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Belge kategorileri tablosu
CREATE TABLE document_categories (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES document_categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Müvekkil talepleri tablosu
CREATE TABLE client_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    request TEXT NOT NULL,
    is_completed BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- SMS doğrulama kodları tablosu
CREATE TABLE verification_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    phone_number VARCHAR(20) NOT NULL,
    code VARCHAR(6) NOT NULL,
    is_used BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL
);

-- İkinci taraf kullanıcıları tablosu
CREATE TABLE second_party_users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lawyer_id VARCHAR(100) NOT NULL,
    full_name VARCHAR(200) NOT NULL,
    phone_number VARCHAR(20) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Giriş kayıtları tablosu
CREATE TABLE login_records (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(100) NOT NULL,
    login_time TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    logout_time TIMESTAMP WITH TIME ZONE,
    login_type VARCHAR(50) NOT NULL, -- 'biometric', 'sms', 'second_party'
    device_info TEXT
);

-- İndeksler
CREATE INDEX idx_clients_tc_no ON clients(tc_no);
CREATE INDEX idx_payments_client_id ON payments(client_id);
CREATE INDEX idx_payment_commitments_client_id ON payment_commitments(client_id);
CREATE INDEX idx_payment_commitments_date ON payment_commitments(commitment_date);
CREATE INDEX idx_court_dates_client_id ON court_dates(client_id);
CREATE INDEX idx_court_dates_date ON court_dates(court_date);
CREATE INDEX idx_client_documents_client_id ON client_documents(client_id);
CREATE INDEX idx_verification_codes_phone ON verification_codes(phone_number);
CREATE INDEX idx_second_party_users_lawyer ON second_party_users(lawyer_id);
CREATE INDEX idx_login_records_user ON login_records(user_id);

-- Row Level Security (RLS) politikaları
ALTER TABLE clients ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE payment_commitments ENABLE ROW LEVEL SECURITY;
ALTER TABLE court_dates ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE document_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE client_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE verification_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE second_party_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE login_records ENABLE ROW LEVEL SECURITY;

-- RLS politikaları (development için - production'da özelleştirin)
CREATE POLICY "Allow all for authenticated users" ON clients FOR ALL USING (true);
CREATE POLICY "Allow all for authenticated users" ON payments FOR ALL USING (true);
CREATE POLICY "Allow all for authenticated users" ON payment_commitments FOR ALL USING (true);
CREATE POLICY "Allow all for authenticated users" ON court_dates FOR ALL USING (true);
CREATE POLICY "Allow all for authenticated users" ON client_documents FOR ALL USING (true);
CREATE POLICY "Allow all for authenticated users" ON document_categories FOR ALL USING (true);
CREATE POLICY "Allow all for authenticated users" ON client_requests FOR ALL USING (true);
CREATE POLICY "Allow all for authenticated users" ON verification_codes FOR ALL USING (true);
CREATE POLICY "Allow all for authenticated users" ON second_party_users FOR ALL USING (true);
CREATE POLICY "Allow all for authenticated users" ON login_records FOR ALL USING (true);

-- Trigger: Ödeme yapıldığında müvekkilin paid_amount'ını güncelle
CREATE OR REPLACE FUNCTION update_client_paid_amount()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_income = true AND NEW.payment_type = 'payment' THEN
        UPDATE clients 
        SET paid_amount = paid_amount + NEW.amount,
            updated_at = NOW()
        WHERE id = NEW.client_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_paid_amount
AFTER INSERT ON payments
FOR EACH ROW
EXECUTE FUNCTION update_client_paid_amount();

-- Trigger: Müvekkil güncellendiğinde updated_at'i güncelle
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_client_timestamp
BEFORE UPDATE ON clients
FOR EACH ROW
EXECUTE FUNCTION update_updated_at();

-- Güvenlik PIN Kodları Tablosu
CREATE TABLE IF NOT EXISTS security_pins (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lawyer_id VARCHAR(100) UNIQUE NOT NULL,
    pin_code VARCHAR(4) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Resmi Evraklar Tablosu (Official Documents)
CREATE TABLE IF NOT EXISTS official_documents (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    client_id UUID REFERENCES clients(id) ON DELETE CASCADE,
    file_name VARCHAR(255) NOT NULL,
    file_path TEXT NOT NULL,
    file_size INTEGER, -- bytes cinsinden
    document_type VARCHAR(100), -- 'contract', 'court_decision', 'letter', etc.
    description TEXT,
    is_confidential BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_by VARCHAR(100) NOT NULL
);

-- Resmi Evraklar Erişim Günlüğü
CREATE TABLE IF NOT EXISTS official_documents_access_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lawyer_id VARCHAR(100) NOT NULL,
    accessed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    exited_at TIMESTAMP WITH TIME ZONE,
    action VARCHAR(50), -- 'login', 'logout', 'view', 'download'
    document_id UUID REFERENCES official_documents(id) ON DELETE SET NULL,
    ip_address VARCHAR(50),
    device_info TEXT
);

-- Index'ler
CREATE INDEX IF NOT EXISTS idx_security_pins_lawyer_id ON security_pins(lawyer_id);
CREATE INDEX IF NOT EXISTS idx_official_documents_client_id ON official_documents(client_id);
CREATE INDEX IF NOT EXISTS idx_official_documents_created_at ON official_documents(created_at);
CREATE INDEX IF NOT EXISTS idx_documents_access_log_lawyer ON official_documents_access_log(lawyer_id);
CREATE INDEX IF NOT EXISTS idx_documents_access_log_accessed_at ON official_documents_access_log(accessed_at);

-- RLS Politikaları
ALTER TABLE security_pins ENABLE ROW LEVEL SECURITY;
ALTER TABLE official_documents ENABLE ROW LEVEL SECURITY;
ALTER TABLE official_documents_access_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow all for authenticated users" ON security_pins FOR ALL USING (true);
CREATE POLICY "Allow all for authenticated users" ON official_documents FOR ALL USING (true);
CREATE POLICY "Allow all for authenticated users" ON official_documents_access_log FOR ALL USING (true);

-- Trigger: updated_at güncelleme
CREATE OR REPLACE FUNCTION update_security_pins_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_security_pins_timestamp
BEFORE UPDATE ON security_pins
FOR EACH ROW
EXECUTE FUNCTION update_security_pins_timestamp();

CREATE OR REPLACE FUNCTION update_official_documents_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_official_documents_timestamp
BEFORE UPDATE ON official_documents
FOR EACH ROW
EXECUTE FUNCTION update_official_documents_timestamp();

-- Resmi Evraklar Aktivite Günlüğü (Activity Log)
CREATE TABLE IF NOT EXISTS official_documents_activity_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    lawyer_id VARCHAR(100) NOT NULL,
    document_id UUID REFERENCES official_documents(id) ON DELETE CASCADE,
    document_name VARCHAR(255) NOT NULL,
    action VARCHAR(50) NOT NULL, -- 'upload', 'download', 'share', 'delete', 'view'
    action_details TEXT, -- JSON olarak ek bilgiler (kime paylaşıldı vb.)
    shared_with VARCHAR(255), -- paylaşılan kişi/email
    ip_address VARCHAR(50),
    device_info TEXT,
    activity_timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index'ler
CREATE INDEX IF NOT EXISTS idx_activity_log_lawyer_id ON official_documents_activity_log(lawyer_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_document_id ON official_documents_activity_log(document_id);
CREATE INDEX IF NOT EXISTS idx_activity_log_timestamp ON official_documents_activity_log(activity_timestamp);
CREATE INDEX IF NOT EXISTS idx_activity_log_action ON official_documents_activity_log(action);

-- RLS Policy
ALTER TABLE official_documents_activity_log ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Allow all for authenticated users" ON official_documents_activity_log FOR ALL USING (true);

-- Trigger: Activity log timestamp
CREATE OR REPLACE FUNCTION update_activity_log_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.activity_timestamp = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_activity_log_timestamp
BEFORE UPDATE ON official_documents_activity_log
FOR EACH ROW
EXECUTE FUNCTION update_activity_log_timestamp();
