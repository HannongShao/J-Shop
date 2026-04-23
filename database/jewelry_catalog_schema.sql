-- Jewelry catalog backend schema
-- Target database: PostgreSQL 15+
-- Purpose:
-- 1. Keep jewelry catalog, care, size, and inventory data structured.
-- 2. Make admin updates easier for materials, finishes, gemstones, and care guides.
-- 3. Flatten relational data into Shopify-friendly fields through views.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DO $$
BEGIN
  CREATE TYPE catalog_status AS ENUM ('draft', 'active', 'archived');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE jewelry_product_type AS ENUM ('ring', 'earrings', 'necklace', 'bracelet', 'pendant', 'set', 'other');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE material_role AS ENUM ('base_metal', 'surface_material', 'accent_material');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE gemstone_role AS ENUM ('center', 'accent', 'pave', 'pearl', 'other');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE finish_type AS ENUM ('plating', 'polish', 'texture', 'coating');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE care_step_type AS ENUM ('avoid', 'clean', 'store', 'wearing_tip', 'maintenance');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE badge_type AS ENUM ('gift_ready', 'daily_layering', 'occasion_anchor', 'sensitive_skin', 'limited_drop');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE inventory_movement_type AS ENUM ('manual_adjustment', 'purchase', 'sale', 'return', 'reservation', 'release');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE customer_stage AS ENUM ('lead', 'prospect', 'client', 'vip', 'inactive');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE contact_channel AS ENUM ('email', 'phone', 'sms', 'whatsapp', 'wechat', 'instagram', 'other');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE shopping_intent AS ENUM ('gift', 'self_purchase', 'occasion', 'bridal', 'other');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE consultation_type AS ENUM ('gift_concierge', 'styling', 'bridal', 'vip_followup');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE consultation_status AS ENUM ('new', 'qualified', 'scheduled', 'completed', 'converted', 'closed');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE passport_status AS ENUM ('registered', 'active', 'in_service', 'archived');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE service_request_type AS ENUM ('cleaning', 'repair', 'resize', 'replating', 'stone_check', 'stringing', 'authentication', 'other');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE service_request_status AS ENUM ('submitted', 'triaged', 'quoted', 'approved', 'in_progress', 'ready_to_ship', 'completed', 'cancelled');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  CREATE TYPE passport_event_type AS ENUM ('registration', 'purchase', 'gifted', 'service', 'resize', 'repair', 'replating', 'cleaning', 'inspection');
EXCEPTION
  WHEN duplicate_object THEN NULL;
END $$;

CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

CREATE TABLE IF NOT EXISTS collections (
  id BIGSERIAL PRIMARY KEY,
  handle TEXT NOT NULL UNIQUE,
  title_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  description_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  status catalog_status NOT NULL DEFAULT 'draft',
  display_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS shipping_profiles (
  id BIGSERIAL PRIMARY KEY,
  handle TEXT NOT NULL UNIQUE,
  label TEXT NOT NULL,
  domestic_dispatch_min_days SMALLINT NOT NULL DEFAULT 1,
  domestic_dispatch_max_days SMALLINT NOT NULL DEFAULT 3,
  domestic_delivery_min_days SMALLINT,
  domestic_delivery_max_days SMALLINT,
  international_dispatch_min_days SMALLINT,
  international_dispatch_max_days SMALLINT,
  express_available BOOLEAN NOT NULL DEFAULT TRUE,
  free_shipping_threshold NUMERIC(10, 2),
  returns_window_days SMALLINT NOT NULL DEFAULT 30,
  public_note_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  admin_note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS size_guides (
  id BIGSERIAL PRIMARY KEY,
  handle TEXT NOT NULL UNIQUE,
  label TEXT NOT NULL,
  applies_to jewelry_product_type NOT NULL,
  unit_system TEXT NOT NULL DEFAULT 'metric',
  summary_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  status catalog_status NOT NULL DEFAULT 'draft',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS size_guide_rows (
  id BIGSERIAL PRIMARY KEY,
  size_guide_id BIGINT NOT NULL REFERENCES size_guides(id) ON DELETE CASCADE,
  display_order INTEGER NOT NULL DEFAULT 0,
  label TEXT NOT NULL,
  eu_size TEXT,
  us_size TEXT,
  uk_size TEXT,
  inner_diameter_mm NUMERIC(6, 2),
  circumference_mm NUMERIC(6, 2),
  length_cm NUMERIC(6, 2),
  width_mm NUMERIC(6, 2),
  fit_note_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  UNIQUE (size_guide_id, label)
);

CREATE TABLE IF NOT EXISTS care_guides (
  id BIGSERIAL PRIMARY KEY,
  handle TEXT NOT NULL UNIQUE,
  label TEXT NOT NULL,
  target_scope TEXT NOT NULL,
  title_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  summary_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  status catalog_status NOT NULL DEFAULT 'draft',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS care_steps (
  id BIGSERIAL PRIMARY KEY,
  care_guide_id BIGINT NOT NULL REFERENCES care_guides(id) ON DELETE CASCADE,
  display_order INTEGER NOT NULL DEFAULT 0,
  step_type care_step_type NOT NULL,
  title_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  instruction_i18n JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS materials (
  id BIGSERIAL PRIMARY KEY,
  handle TEXT NOT NULL UNIQUE,
  material_group TEXT NOT NULL,
  name_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  summary_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  hypoallergenic BOOLEAN NOT NULL DEFAULT FALSE,
  tarnish_risk TEXT,
  water_exposure_level TEXT,
  default_care_guide_id BIGINT REFERENCES care_guides(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS finishes (
  id BIGSERIAL PRIMARY KEY,
  handle TEXT NOT NULL UNIQUE,
  finish_kind finish_type NOT NULL,
  name_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  summary_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  color_tone TEXT,
  thickness_microns NUMERIC(8, 2),
  default_care_guide_id BIGINT REFERENCES care_guides(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS gemstones (
  id BIGSERIAL PRIMARY KEY,
  handle TEXT NOT NULL UNIQUE,
  gemstone_group TEXT NOT NULL,
  name_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  summary_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  hardness_mohs NUMERIC(4, 2),
  luster TEXT,
  origin_note_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  default_care_guide_id BIGINT REFERENCES care_guides(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS badges (
  id BIGSERIAL PRIMARY KEY,
  code badge_type NOT NULL UNIQUE,
  label_i18n JSONB NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE IF NOT EXISTS products (
  id BIGSERIAL PRIMARY KEY,
  handle TEXT NOT NULL UNIQUE,
  product_type jewelry_product_type NOT NULL,
  status catalog_status NOT NULL DEFAULT 'draft',
  sku_prefix TEXT,
  shipping_profile_id BIGINT REFERENCES shipping_profiles(id),
  size_guide_id BIGINT REFERENCES size_guides(id),
  gift_ready BOOLEAN NOT NULL DEFAULT FALSE,
  gift_message_supported BOOLEAN NOT NULL DEFAULT FALSE,
  is_personalizable BOOLEAN NOT NULL DEFAULT FALSE,
  featured_score INTEGER NOT NULL DEFAULT 0,
  display_order INTEGER NOT NULL DEFAULT 0,
  default_currency CHAR(3) NOT NULL DEFAULT 'AUD',
  admin_label TEXT,
  merch_notes TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS product_content (
  id BIGSERIAL PRIMARY KEY,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  locale TEXT NOT NULL CHECK (locale IN ('en-AU', 'zh-CN')),
  title TEXT NOT NULL,
  short_blurb TEXT,
  description_html TEXT,
  shipping_note_override TEXT,
  care_summary_override TEXT,
  skin_friendly_note TEXT,
  seo_title TEXT,
  seo_description TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE (product_id, locale)
);

CREATE TABLE IF NOT EXISTS product_variants (
  id BIGSERIAL PRIMARY KEY,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  sku TEXT NOT NULL UNIQUE,
  option1_name TEXT DEFAULT 'Size',
  option1_value TEXT,
  option2_name TEXT,
  option2_value TEXT,
  option3_name TEXT,
  option3_value TEXT,
  price NUMERIC(10, 2) NOT NULL,
  compare_at_price NUMERIC(10, 2),
  cost_price NUMERIC(10, 2),
  currency CHAR(3) NOT NULL DEFAULT 'AUD',
  weight_grams NUMERIC(8, 2),
  inventory_quantity INTEGER NOT NULL DEFAULT 0,
  reserved_quantity INTEGER NOT NULL DEFAULT 0,
  reorder_point INTEGER NOT NULL DEFAULT 0,
  is_default BOOLEAN NOT NULL DEFAULT FALSE,
  is_active BOOLEAN NOT NULL DEFAULT TRUE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS inventory_movements (
  id BIGSERIAL PRIMARY KEY,
  variant_id BIGINT NOT NULL REFERENCES product_variants(id) ON DELETE CASCADE,
  movement_type inventory_movement_type NOT NULL,
  quantity_delta INTEGER NOT NULL,
  reference_type TEXT,
  reference_id TEXT,
  note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS product_media (
  id BIGSERIAL PRIMARY KEY,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  media_type TEXT NOT NULL,
  source_url TEXT NOT NULL,
  alt_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  admin_note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS product_collection_memberships (
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  collection_id BIGINT NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
  sort_order INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (product_id, collection_id)
);

CREATE TABLE IF NOT EXISTS product_materials (
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  material_id BIGINT NOT NULL REFERENCES materials(id),
  role material_role NOT NULL DEFAULT 'base_metal',
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  composition_percent NUMERIC(5, 2),
  display_order INTEGER NOT NULL DEFAULT 0,
  note_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  PRIMARY KEY (product_id, material_id, role)
);

CREATE TABLE IF NOT EXISTS product_finishes (
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  finish_id BIGINT NOT NULL REFERENCES finishes(id),
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  display_order INTEGER NOT NULL DEFAULT 0,
  note_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  PRIMARY KEY (product_id, finish_id)
);

CREATE TABLE IF NOT EXISTS product_gemstones (
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  gemstone_id BIGINT NOT NULL REFERENCES gemstones(id),
  role gemstone_role NOT NULL DEFAULT 'accent',
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  stone_count INTEGER NOT NULL DEFAULT 1,
  carat_weight NUMERIC(8, 3),
  cut_label TEXT,
  display_order INTEGER NOT NULL DEFAULT 0,
  note_i18n JSONB NOT NULL DEFAULT '{}'::jsonb,
  PRIMARY KEY (product_id, gemstone_id, role)
);

CREATE TABLE IF NOT EXISTS product_care_guides (
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  care_guide_id BIGINT NOT NULL REFERENCES care_guides(id),
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  display_order INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (product_id, care_guide_id)
);

CREATE TABLE IF NOT EXISTS product_badges (
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  badge_id BIGINT NOT NULL REFERENCES badges(id),
  display_order INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (product_id, badge_id)
);

CREATE TABLE IF NOT EXISTS catalog_change_log (
  id BIGSERIAL PRIMARY KEY,
  entity_name TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  action_name TEXT NOT NULL,
  changed_by TEXT,
  diff JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS customers (
  id BIGSERIAL PRIMARY KEY,
  external_customer_ref TEXT UNIQUE,
  stage customer_stage NOT NULL DEFAULT 'lead',
  email TEXT UNIQUE,
  phone TEXT,
  first_name TEXT,
  last_name TEXT,
  preferred_locale TEXT NOT NULL DEFAULT 'en-AU',
  preferred_currency CHAR(3) NOT NULL DEFAULT 'AUD',
  country_code CHAR(2) NOT NULL DEFAULT 'AU',
  birth_month SMALLINT CHECK (birth_month BETWEEN 1 AND 12),
  marketing_consent_email BOOLEAN NOT NULL DEFAULT FALSE,
  marketing_consent_sms BOOLEAN NOT NULL DEFAULT FALSE,
  acquisition_source TEXT,
  admin_note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS customer_addresses (
  id BIGSERIAL PRIMARY KEY,
  customer_id BIGINT NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  label TEXT NOT NULL DEFAULT 'Primary',
  recipient_name TEXT,
  phone TEXT,
  line1 TEXT NOT NULL,
  line2 TEXT,
  city TEXT NOT NULL,
  state_region TEXT,
  postal_code TEXT,
  country_code CHAR(2) NOT NULL DEFAULT 'AU',
  is_default_shipping BOOLEAN NOT NULL DEFAULT FALSE,
  is_default_billing BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS customer_profiles (
  customer_id BIGINT PRIMARY KEY REFERENCES customers(id) ON DELETE CASCADE,
  primary_intent shopping_intent NOT NULL DEFAULT 'gift',
  preferred_metal TEXT,
  preferred_stone TEXT,
  ring_size_label TEXT,
  wrist_size_cm NUMERIC(6, 2),
  necklace_length_cm NUMERIC(6, 2),
  sensitive_skin BOOLEAN NOT NULL DEFAULT FALSE,
  style_keywords TEXT[] NOT NULL DEFAULT ARRAY[]::TEXT[],
  gifting_notes TEXT,
  admin_note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS consultations (
  id BIGSERIAL PRIMARY KEY,
  consultation_code TEXT NOT NULL UNIQUE,
  customer_id BIGINT REFERENCES customers(id) ON DELETE SET NULL,
  consultation_type consultation_type NOT NULL DEFAULT 'gift_concierge',
  status consultation_status NOT NULL DEFAULT 'new',
  intent shopping_intent NOT NULL DEFAULT 'gift',
  preferred_contact_channel contact_channel NOT NULL DEFAULT 'email',
  preferred_locale TEXT NOT NULL DEFAULT 'en-AU',
  budget_min NUMERIC(10, 2),
  budget_max NUMERIC(10, 2),
  currency CHAR(3) NOT NULL DEFAULT 'AUD',
  recipient_relation TEXT,
  occasion_name TEXT,
  occasion_date DATE,
  requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  scheduled_for TIMESTAMPTZ,
  brief_text TEXT,
  internal_notes TEXT,
  converted_product_id BIGINT REFERENCES products(id),
  converted_order_ref TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS consultation_recommendations (
  id BIGSERIAL PRIMARY KEY,
  consultation_id BIGINT NOT NULL REFERENCES consultations(id) ON DELETE CASCADE,
  product_id BIGINT NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  variant_id BIGINT REFERENCES product_variants(id) ON DELETE SET NULL,
  rationale TEXT,
  sort_order INTEGER NOT NULL DEFAULT 0,
  is_primary BOOLEAN NOT NULL DEFAULT FALSE,
  selected BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS jewelry_passports (
  id BIGSERIAL PRIMARY KEY,
  passport_code TEXT NOT NULL UNIQUE,
  product_id BIGINT NOT NULL REFERENCES products(id),
  variant_id BIGINT REFERENCES product_variants(id),
  owner_customer_id BIGINT REFERENCES customers(id) ON DELETE SET NULL,
  purchaser_customer_id BIGINT REFERENCES customers(id) ON DELETE SET NULL,
  external_order_ref TEXT,
  purchase_date DATE,
  gifted_on DATE,
  warranty_expires_on DATE,
  status passport_status NOT NULL DEFAULT 'registered',
  care_plan_handle TEXT,
  last_service_at TIMESTAMPTZ,
  internal_note TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS service_requests (
  id BIGSERIAL PRIMARY KEY,
  service_code TEXT NOT NULL UNIQUE,
  customer_id BIGINT REFERENCES customers(id) ON DELETE SET NULL,
  passport_id BIGINT REFERENCES jewelry_passports(id) ON DELETE SET NULL,
  product_id BIGINT REFERENCES products(id) ON DELETE SET NULL,
  variant_id BIGINT REFERENCES product_variants(id) ON DELETE SET NULL,
  request_type service_request_type NOT NULL,
  status service_request_status NOT NULL DEFAULT 'submitted',
  intake_channel contact_channel NOT NULL DEFAULT 'email',
  issue_summary TEXT NOT NULL,
  customer_note TEXT,
  admin_note TEXT,
  quoted_amount NUMERIC(10, 2),
  quote_currency CHAR(3) NOT NULL DEFAULT 'AUD',
  approved_at TIMESTAMPTZ,
  received_at TIMESTAMPTZ,
  due_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ,
  return_tracking_code TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS service_request_updates (
  id BIGSERIAL PRIMARY KEY,
  service_request_id BIGINT NOT NULL REFERENCES service_requests(id) ON DELETE CASCADE,
  status service_request_status NOT NULL,
  public_message TEXT,
  internal_message TEXT,
  internal_only BOOLEAN NOT NULL DEFAULT FALSE,
  created_by TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS passport_events (
  id BIGSERIAL PRIMARY KEY,
  passport_id BIGINT NOT NULL REFERENCES jewelry_passports(id) ON DELETE CASCADE,
  event_type passport_event_type NOT NULL,
  service_request_id BIGINT REFERENCES service_requests(id) ON DELETE SET NULL,
  event_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  description TEXT,
  event_meta JSONB NOT NULL DEFAULT '{}'::jsonb,
  created_by TEXT
);

CREATE INDEX IF NOT EXISTS idx_products_status ON products(status);
CREATE INDEX IF NOT EXISTS idx_products_type_status ON products(product_type, status);
CREATE INDEX IF NOT EXISTS idx_product_content_locale ON product_content(locale);
CREATE INDEX IF NOT EXISTS idx_product_variants_product_id ON product_variants(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_movements_variant_id ON inventory_movements(variant_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_product_materials_product_id ON product_materials(product_id, display_order);
CREATE INDEX IF NOT EXISTS idx_product_finishes_product_id ON product_finishes(product_id, display_order);
CREATE INDEX IF NOT EXISTS idx_product_gemstones_product_id ON product_gemstones(product_id, display_order);
CREATE INDEX IF NOT EXISTS idx_product_care_guides_product_id ON product_care_guides(product_id, display_order);
CREATE INDEX IF NOT EXISTS idx_product_collections_collection_id ON product_collection_memberships(collection_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_customers_stage ON customers(stage);
CREATE INDEX IF NOT EXISTS idx_customers_email ON customers(email);
CREATE INDEX IF NOT EXISTS idx_customer_addresses_customer_id ON customer_addresses(customer_id);
CREATE INDEX IF NOT EXISTS idx_consultations_status_requested ON consultations(status, requested_at DESC);
CREATE INDEX IF NOT EXISTS idx_consultations_customer_id ON consultations(customer_id, requested_at DESC);
CREATE INDEX IF NOT EXISTS idx_consultation_recommendations_consultation_id ON consultation_recommendations(consultation_id, sort_order);
CREATE INDEX IF NOT EXISTS idx_jewelry_passports_owner ON jewelry_passports(owner_customer_id, purchase_date DESC);
CREATE INDEX IF NOT EXISTS idx_jewelry_passports_product ON jewelry_passports(product_id, purchase_date DESC);
CREATE INDEX IF NOT EXISTS idx_service_requests_status_due_at ON service_requests(status, due_at);
CREATE INDEX IF NOT EXISTS idx_service_requests_customer_id ON service_requests(customer_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_service_requests_passport_id ON service_requests(passport_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_passport_events_passport_id ON passport_events(passport_id, event_at DESC);

DROP TRIGGER IF EXISTS trg_collections_updated_at ON collections;
CREATE TRIGGER trg_collections_updated_at BEFORE UPDATE ON collections FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_shipping_profiles_updated_at ON shipping_profiles;
CREATE TRIGGER trg_shipping_profiles_updated_at BEFORE UPDATE ON shipping_profiles FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_size_guides_updated_at ON size_guides;
CREATE TRIGGER trg_size_guides_updated_at BEFORE UPDATE ON size_guides FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_care_guides_updated_at ON care_guides;
CREATE TRIGGER trg_care_guides_updated_at BEFORE UPDATE ON care_guides FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_materials_updated_at ON materials;
CREATE TRIGGER trg_materials_updated_at BEFORE UPDATE ON materials FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_finishes_updated_at ON finishes;
CREATE TRIGGER trg_finishes_updated_at BEFORE UPDATE ON finishes FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_gemstones_updated_at ON gemstones;
CREATE TRIGGER trg_gemstones_updated_at BEFORE UPDATE ON gemstones FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_products_updated_at ON products;
CREATE TRIGGER trg_products_updated_at BEFORE UPDATE ON products FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_product_content_updated_at ON product_content;
CREATE TRIGGER trg_product_content_updated_at BEFORE UPDATE ON product_content FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_product_variants_updated_at ON product_variants;
CREATE TRIGGER trg_product_variants_updated_at BEFORE UPDATE ON product_variants FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_customers_updated_at ON customers;
CREATE TRIGGER trg_customers_updated_at BEFORE UPDATE ON customers FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_customer_addresses_updated_at ON customer_addresses;
CREATE TRIGGER trg_customer_addresses_updated_at BEFORE UPDATE ON customer_addresses FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_customer_profiles_updated_at ON customer_profiles;
CREATE TRIGGER trg_customer_profiles_updated_at BEFORE UPDATE ON customer_profiles FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_consultations_updated_at ON consultations;
CREATE TRIGGER trg_consultations_updated_at BEFORE UPDATE ON consultations FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_jewelry_passports_updated_at ON jewelry_passports;
CREATE TRIGGER trg_jewelry_passports_updated_at BEFORE UPDATE ON jewelry_passports FOR EACH ROW EXECUTE FUNCTION set_updated_at();

DROP TRIGGER IF EXISTS trg_service_requests_updated_at ON service_requests;
CREATE TRIGGER trg_service_requests_updated_at BEFORE UPDATE ON service_requests FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE OR REPLACE VIEW vw_admin_product_overview AS
SELECT
  p.id,
  p.handle,
  p.product_type,
  p.status,
  p.gift_ready,
  p.gift_message_supported,
  p.is_personalizable,
  pc_en.title AS title_en_au,
  pc_zh.title AS title_zh_cn,
  COALESCE(price_info.min_price, 0) AS min_price_aud,
  COALESCE(price_info.max_price, 0) AS max_price_aud,
  COALESCE(stock_info.available_units, 0) AS available_units,
  sg.handle AS size_guide_handle,
  sp.handle AS shipping_profile_handle,
  material_info.materials_en,
  finish_info.finishes_en,
  gemstone_info.gemstones_en,
  primary_care.primary_care_handle,
  p.updated_at
FROM products p
LEFT JOIN product_content pc_en
  ON pc_en.product_id = p.id
 AND pc_en.locale = 'en-AU'
LEFT JOIN product_content pc_zh
  ON pc_zh.product_id = p.id
 AND pc_zh.locale = 'zh-CN'
LEFT JOIN size_guides sg
  ON sg.id = p.size_guide_id
LEFT JOIN shipping_profiles sp
  ON sp.id = p.shipping_profile_id
LEFT JOIN LATERAL (
  SELECT
    MIN(v.price) AS min_price,
    MAX(v.price) AS max_price
  FROM product_variants v
  WHERE v.product_id = p.id
    AND v.is_active = TRUE
) AS price_info ON TRUE
LEFT JOIN LATERAL (
  SELECT
    SUM(GREATEST(v.inventory_quantity - v.reserved_quantity, 0)) AS available_units
  FROM product_variants v
  WHERE v.product_id = p.id
    AND v.is_active = TRUE
) AS stock_info ON TRUE
LEFT JOIN LATERAL (
  SELECT STRING_AGG(COALESCE(m.name_i18n ->> 'en-AU', m.handle), ', ' ORDER BY pm.display_order) AS materials_en
  FROM product_materials pm
  JOIN materials m ON m.id = pm.material_id
  WHERE pm.product_id = p.id
) AS material_info ON TRUE
LEFT JOIN LATERAL (
  SELECT STRING_AGG(COALESCE(f.name_i18n ->> 'en-AU', f.handle), ', ' ORDER BY pf.display_order) AS finishes_en
  FROM product_finishes pf
  JOIN finishes f ON f.id = pf.finish_id
  WHERE pf.product_id = p.id
) AS finish_info ON TRUE
LEFT JOIN LATERAL (
  SELECT STRING_AGG(COALESCE(g.name_i18n ->> 'en-AU', g.handle), ', ' ORDER BY pg.display_order) AS gemstones_en
  FROM product_gemstones pg
  JOIN gemstones g ON g.id = pg.gemstone_id
  WHERE pg.product_id = p.id
) AS gemstone_info ON TRUE
LEFT JOIN LATERAL (
  SELECT cg.handle AS primary_care_handle
  FROM product_care_guides pcg
  JOIN care_guides cg ON cg.id = pcg.care_guide_id
  WHERE pcg.product_id = p.id
  ORDER BY pcg.is_primary DESC, pcg.display_order ASC
  LIMIT 1
) AS primary_care ON TRUE;

CREATE OR REPLACE VIEW vw_admin_product_care_matrix AS
SELECT
  p.handle AS product_handle,
  pc.locale,
  pc.title,
  cg.handle AS care_guide_handle,
  COALESCE(cg.title_i18n ->> pc.locale, cg.title_i18n ->> 'en-AU', cg.label) AS care_guide_title,
  COALESCE(pc.care_summary_override, cg.summary_i18n ->> pc.locale, cg.summary_i18n ->> 'en-AU') AS care_summary,
  (
    SELECT STRING_AGG(COALESCE(cs.instruction_i18n ->> pc.locale, cs.instruction_i18n ->> 'en-AU'), ' | ' ORDER BY cs.display_order)
    FROM care_steps cs
    WHERE cs.care_guide_id = cg.id
  ) AS ordered_steps
FROM products p
JOIN product_content pc
  ON pc.product_id = p.id
LEFT JOIN product_care_guides pcg
  ON pcg.product_id = p.id
LEFT JOIN care_guides cg
  ON cg.id = pcg.care_guide_id;

CREATE OR REPLACE VIEW vw_shopify_product_custom_data AS
SELECT
  p.handle,
  pc.locale,
  pc.title,
  pc.short_blurb,
  material_data.material_primary,
  finish_data.plating_info,
  gemstone_data.gemstone_type,
  pc.skin_friendly_note,
  COALESCE(pc.shipping_note_override, shipping_data.shipping_note) AS shipping_note,
  COALESCE(pc.care_summary_override, care_data.care_summary) AS care_summary,
  p.gift_ready,
  size_data.size_chart
FROM products p
JOIN product_content pc
  ON pc.product_id = p.id
LEFT JOIN LATERAL (
  SELECT STRING_AGG(COALESCE(m.name_i18n ->> pc.locale, m.name_i18n ->> 'en-AU', m.handle), ', ' ORDER BY pm.display_order) AS material_primary
  FROM product_materials pm
  JOIN materials m ON m.id = pm.material_id
  WHERE pm.product_id = p.id
    AND pm.is_primary = TRUE
) AS material_data ON TRUE
LEFT JOIN LATERAL (
  SELECT STRING_AGG(COALESCE(f.name_i18n ->> pc.locale, f.name_i18n ->> 'en-AU', f.handle), ', ' ORDER BY pf.display_order) AS plating_info
  FROM product_finishes pf
  JOIN finishes f ON f.id = pf.finish_id
  WHERE pf.product_id = p.id
    AND pf.is_primary = TRUE
) AS finish_data ON TRUE
LEFT JOIN LATERAL (
  SELECT STRING_AGG(COALESCE(g.name_i18n ->> pc.locale, g.name_i18n ->> 'en-AU', g.handle), ', ' ORDER BY pg.display_order) AS gemstone_type
  FROM product_gemstones pg
  JOIN gemstones g ON g.id = pg.gemstone_id
  WHERE pg.product_id = p.id
    AND pg.is_primary = TRUE
) AS gemstone_data ON TRUE
LEFT JOIN LATERAL (
  SELECT COALESCE(sp.public_note_i18n ->> pc.locale, sp.public_note_i18n ->> 'en-AU') AS shipping_note
  FROM shipping_profiles sp
  WHERE sp.id = p.shipping_profile_id
) AS shipping_data ON TRUE
LEFT JOIN LATERAL (
  SELECT COALESCE(sg.summary_i18n ->> pc.locale, sg.summary_i18n ->> 'en-AU') AS size_chart
  FROM size_guides sg
  WHERE sg.id = p.size_guide_id
) AS size_data ON TRUE
LEFT JOIN LATERAL (
  SELECT COALESCE(cg.summary_i18n ->> pc.locale, cg.summary_i18n ->> 'en-AU') AS care_summary
  FROM product_care_guides pcg
  JOIN care_guides cg ON cg.id = pcg.care_guide_id
  WHERE pcg.product_id = p.id
  ORDER BY pcg.is_primary DESC, pcg.display_order ASC
  LIMIT 1
) AS care_data ON TRUE;

CREATE OR REPLACE VIEW vw_admin_customer_overview AS
SELECT
  c.id,
  c.stage,
  c.email,
  c.phone,
  CONCAT_WS(' ', c.first_name, c.last_name) AS customer_name,
  c.preferred_locale,
  c.marketing_consent_email,
  c.marketing_consent_sms,
  cp.primary_intent,
  cp.preferred_metal,
  cp.preferred_stone,
  cp.sensitive_skin,
  COALESCE(passport_counts.passports_owned, 0) AS passports_owned,
  COALESCE(consult_counts.open_consultations, 0) AS open_consultations,
  COALESCE(service_counts.active_services, 0) AS active_services,
  consult_counts.last_consultation_at,
  service_counts.last_service_at,
  c.updated_at
FROM customers c
LEFT JOIN customer_profiles cp
  ON cp.customer_id = c.id
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) FILTER (WHERE jp.status <> 'archived') AS passports_owned
  FROM jewelry_passports jp
  WHERE jp.owner_customer_id = c.id
) AS passport_counts ON TRUE
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) FILTER (WHERE ct.status IN ('new', 'qualified', 'scheduled')) AS open_consultations,
    MAX(ct.requested_at) AS last_consultation_at
  FROM consultations ct
  WHERE ct.customer_id = c.id
) AS consult_counts ON TRUE
LEFT JOIN LATERAL (
  SELECT
    COUNT(*) FILTER (WHERE sr.status IN ('submitted', 'triaged', 'quoted', 'approved', 'in_progress', 'ready_to_ship')) AS active_services,
    MAX(sr.created_at) AS last_service_at
  FROM service_requests sr
  WHERE sr.customer_id = c.id
) AS service_counts ON TRUE;

CREATE OR REPLACE VIEW vw_admin_concierge_queue AS
SELECT
  ct.consultation_code,
  ct.consultation_type,
  ct.status,
  ct.intent,
  CONCAT_WS(' ', c.first_name, c.last_name) AS customer_name,
  c.email AS customer_email,
  c.phone AS customer_phone,
  ct.preferred_contact_channel,
  ct.budget_min,
  ct.budget_max,
  ct.currency,
  ct.occasion_name,
  ct.occasion_date,
  ct.requested_at,
  ct.scheduled_for,
  ct.brief_text,
  recs.recommended_handles,
  recs.primary_recommendation_handle,
  ct.converted_order_ref
FROM consultations ct
LEFT JOIN customers c
  ON c.id = ct.customer_id
LEFT JOIN LATERAL (
  SELECT
    STRING_AGG(p.handle, ', ' ORDER BY cr.sort_order) AS recommended_handles,
    MAX(CASE WHEN cr.is_primary THEN p.handle END) AS primary_recommendation_handle
  FROM consultation_recommendations cr
  JOIN products p ON p.id = cr.product_id
  WHERE cr.consultation_id = ct.id
) AS recs ON TRUE
ORDER BY
  CASE ct.status
    WHEN 'new' THEN 1
    WHEN 'qualified' THEN 2
    WHEN 'scheduled' THEN 3
    WHEN 'completed' THEN 4
    WHEN 'converted' THEN 5
    ELSE 6
  END,
  ct.requested_at DESC;

CREATE OR REPLACE VIEW vw_admin_passport_registry AS
SELECT
  jp.passport_code,
  jp.status,
  p.handle AS product_handle,
  pc_en.title AS product_title_en_au,
  pv.sku AS variant_sku,
  CONCAT_WS(' ', owner.first_name, owner.last_name) AS owner_name,
  owner.email AS owner_email,
  CONCAT_WS(' ', purchaser.first_name, purchaser.last_name) AS purchaser_name,
  jp.purchase_date,
  jp.gifted_on,
  jp.warranty_expires_on,
  jp.last_service_at,
  latest_service.service_code AS latest_service_code,
  latest_service.status AS latest_service_status,
  jp.internal_note
FROM jewelry_passports jp
JOIN products p
  ON p.id = jp.product_id
LEFT JOIN product_content pc_en
  ON pc_en.product_id = p.id
 AND pc_en.locale = 'en-AU'
LEFT JOIN product_variants pv
  ON pv.id = jp.variant_id
LEFT JOIN customers owner
  ON owner.id = jp.owner_customer_id
LEFT JOIN customers purchaser
  ON purchaser.id = jp.purchaser_customer_id
LEFT JOIN LATERAL (
  SELECT sr.service_code, sr.status
  FROM service_requests sr
  WHERE sr.passport_id = jp.id
  ORDER BY sr.created_at DESC
  LIMIT 1
) AS latest_service ON TRUE;

CREATE OR REPLACE VIEW vw_admin_aftercare_queue AS
SELECT
  sr.service_code,
  sr.request_type,
  sr.status,
  CONCAT_WS(' ', c.first_name, c.last_name) AS customer_name,
  c.email AS customer_email,
  jp.passport_code,
  p.handle AS product_handle,
  pc_en.title AS product_title_en_au,
  sr.quoted_amount,
  sr.quote_currency,
  sr.received_at,
  sr.due_at,
  sr.completed_at,
  GREATEST(DATE_PART('day', NOW() - sr.created_at), 0)::INTEGER AS days_open,
  sr.issue_summary,
  sr.return_tracking_code
FROM service_requests sr
LEFT JOIN customers c
  ON c.id = sr.customer_id
LEFT JOIN jewelry_passports jp
  ON jp.id = sr.passport_id
LEFT JOIN products p
  ON p.id = COALESCE(sr.product_id, jp.product_id)
LEFT JOIN product_content pc_en
  ON pc_en.product_id = p.id
 AND pc_en.locale = 'en-AU'
ORDER BY
  CASE sr.status
    WHEN 'submitted' THEN 1
    WHEN 'triaged' THEN 2
    WHEN 'quoted' THEN 3
    WHEN 'approved' THEN 4
    WHEN 'in_progress' THEN 5
    WHEN 'ready_to_ship' THEN 6
    ELSE 7
  END,
  sr.created_at DESC;

-- Suggested sync targets for the current theme:
-- short_blurb      -> product.metafields.custom.short_blurb
-- material_primary -> product.metafields.custom.material_primary
-- plating_info     -> product.metafields.custom.plating_info
-- gemstone_type    -> product.metafields.custom.gemstone_type
-- skin_friendly_note -> product.metafields.custom.skin_friendly_note
-- shipping_note    -> product.metafields.custom.shipping_note
-- care_summary     -> product.metafields.custom.care_summary
-- gift_ready       -> product.metafields.custom.gift_ready
-- size_chart       -> product.metafields.custom.size_chart
