-- Sample seed data for the jewelry backend schema
-- Run after `jewelry_catalog_schema.sql`

INSERT INTO shipping_profiles (
  handle,
  label,
  domestic_dispatch_min_days,
  domestic_dispatch_max_days,
  domestic_delivery_min_days,
  domestic_delivery_max_days,
  express_available,
  free_shipping_threshold,
  returns_window_days,
  public_note_i18n,
  admin_note
)
VALUES (
  'au-ready',
  'Australia ready-to-ship',
  1,
  2,
  2,
  5,
  TRUE,
  149.00,
  30,
  '{"en-AU":"Ready to ship from Brisbane within 48 hours.","zh-CN":"布里斯班现货，48 小时内发出。"}'::jsonb,
  'Default domestic profile for hero pieces'
)
ON CONFLICT (handle) DO NOTHING;

INSERT INTO size_guides (
  handle,
  label,
  applies_to,
  summary_i18n,
  status
)
VALUES (
  'earring-core-fit',
  'Earring fit guide',
  'earrings',
  '{"en-AU":"Lightweight drop silhouette suitable for all-day wear.","zh-CN":"轻量耳饰结构，适合日常长时间佩戴。"}'::jsonb,
  'active'
)
ON CONFLICT (handle) DO NOTHING;

INSERT INTO size_guide_rows (
  size_guide_id,
  display_order,
  label,
  length_cm,
  width_mm,
  fit_note_i18n
)
SELECT
  sg.id,
  1,
  'One size',
  2.40,
  10.00,
  '{"en-AU":"Balanced drop length for gifting and daily wear.","zh-CN":"长度适中，适合送礼和日常佩戴。"}'::jsonb
FROM size_guides sg
WHERE sg.handle = 'earring-core-fit'
ON CONFLICT (size_guide_id, label) DO NOTHING;

INSERT INTO care_guides (
  handle,
  label,
  target_scope,
  title_i18n,
  summary_i18n,
  status
)
VALUES
  (
    'gold-vermeil-care',
    'Gold vermeil care',
    'finish',
    '{"en-AU":"Gold vermeil care","zh-CN":"镀金保养"}'::jsonb,
    '{"en-AU":"Avoid perfume, ocean water, and store dry after wear.","zh-CN":"避免香水和海水接触，佩戴后保持干燥收纳。"}'::jsonb,
    'active'
  ),
  (
    'pearl-care',
    'Pearl care',
    'gemstone',
    '{"en-AU":"Pearl care","zh-CN":"珍珠保养"}'::jsonb,
    '{"en-AU":"Wipe gently with a soft cloth and store separately.","zh-CN":"佩戴后以软布轻拭，并单独存放。"}'::jsonb,
    'active'
  )
ON CONFLICT (handle) DO NOTHING;

INSERT INTO care_steps (
  care_guide_id,
  display_order,
  step_type,
  title_i18n,
  instruction_i18n
)
SELECT
  cg.id,
  steps.display_order,
  steps.step_type::care_step_type,
  steps.title_i18n::jsonb,
  steps.instruction_i18n::jsonb
FROM care_guides cg
JOIN (
  VALUES
    ('gold-vermeil-care', 1, 'avoid', '{"en-AU":"Avoid direct sprays","zh-CN":"避免直接喷洒"}', '{"en-AU":"Apply perfume and lotion before putting the piece on.","zh-CN":"先喷香水和乳液，再佩戴珠宝。"}'),
    ('gold-vermeil-care', 2, 'store', '{"en-AU":"Store dry","zh-CN":"干燥存放"}', '{"en-AU":"Keep in a pouch away from humid bathrooms.","zh-CN":"放入收纳袋，避免潮湿环境。"}'),
    ('pearl-care', 1, 'clean', '{"en-AU":"Wipe softly","zh-CN":"轻柔擦拭"}', '{"en-AU":"Use a soft dry cloth after wearing.","zh-CN":"佩戴后使用柔软干布轻拭。"}'),
    ('pearl-care', 2, 'store', '{"en-AU":"Store separately","zh-CN":"单独收纳"}', '{"en-AU":"Keep pearls away from harder pieces to prevent surface marks.","zh-CN":"避免与较硬首饰混放，减少表面刮痕。"}')
) AS steps(handle, display_order, step_type, title_i18n, instruction_i18n)
  ON steps.handle = cg.handle
WHERE NOT EXISTS (
  SELECT 1
  FROM care_steps cs
  WHERE cs.care_guide_id = cg.id
    AND cs.display_order = steps.display_order
);

INSERT INTO materials (
  handle,
  material_group,
  name_i18n,
  summary_i18n,
  hypoallergenic,
  tarnish_risk,
  water_exposure_level,
  default_care_guide_id
)
SELECT
  'sterling-silver',
  'silver',
  '{"en-AU":"Sterling silver","zh-CN":"925 银"}'::jsonb,
  '{"en-AU":"A solid silver base chosen for light fine-jewelry wear.","zh-CN":"适合轻珠宝日常佩戴的 925 银底材。"}'::jsonb,
  TRUE,
  'medium',
  'avoid',
  cg.id
FROM care_guides cg
WHERE cg.handle = 'gold-vermeil-care'
ON CONFLICT (handle) DO NOTHING;

INSERT INTO finishes (
  handle,
  finish_kind,
  name_i18n,
  summary_i18n,
  color_tone,
  thickness_microns,
  default_care_guide_id
)
SELECT
  '18k-gold-vermeil',
  'plating',
  '{"en-AU":"18k gold vermeil","zh-CN":"18K 镀金"}'::jsonb,
  '{"en-AU":"Warm gold finish over sterling silver for a soft polished glow.","zh-CN":"覆盖在 925 银上的暖金色镀层，呈现柔和光泽。"}'::jsonb,
  'warm gold',
  2.50,
  cg.id
FROM care_guides cg
WHERE cg.handle = 'gold-vermeil-care'
ON CONFLICT (handle) DO NOTHING;

INSERT INTO gemstones (
  handle,
  gemstone_group,
  name_i18n,
  summary_i18n,
  hardness_mohs,
  luster,
  origin_note_i18n,
  default_care_guide_id
)
SELECT
  'freshwater-pearl',
  'organic',
  '{"en-AU":"Freshwater pearl","zh-CN":"淡水珍珠"}'::jsonb,
  '{"en-AU":"Soft luster pearl selected for calm everyday elegance.","zh-CN":"柔和光泽的淡水珍珠，适合日常精致佩戴。"}'::jsonb,
  2.50,
  'soft glow',
  '{"en-AU":"Selected for shape and surface harmony.","zh-CN":"以形状与表面和谐度为主要挑选标准。"}'::jsonb,
  cg.id
FROM care_guides cg
WHERE cg.handle = 'pearl-care'
ON CONFLICT (handle) DO NOTHING;

INSERT INTO badges (code, label_i18n)
VALUES
  ('gift_ready', '{"en-AU":"Gift ready","zh-CN":"送礼友好"}'::jsonb),
  ('daily_layering', '{"en-AU":"Daily layering","zh-CN":"适合叠戴"}'::jsonb),
  ('occasion_anchor', '{"en-AU":"Occasion anchor","zh-CN":"场合主打"}'::jsonb),
  ('sensitive_skin', '{"en-AU":"Sensitive skin aware","zh-CN":"敏感肌友好"}'::jsonb),
  ('limited_drop', '{"en-AU":"Limited drop","zh-CN":"限量发售"}'::jsonb)
ON CONFLICT (code) DO NOTHING;

INSERT INTO collections (
  handle,
  title_i18n,
  description_i18n,
  status,
  display_order
)
VALUES
  ('gift-edit', '{"en-AU":"Gift edit","zh-CN":"送礼精选"}'::jsonb, '{"en-AU":"Pieces that feel easy to choose and elegant to receive.","zh-CN":"更容易选择，也更适合送出的珠宝作品。"}'::jsonb, 'active', 10),
  ('daily-edit', '{"en-AU":"Daily edit","zh-CN":"日常精选"}'::jsonb, '{"en-AU":"Light everyday pieces for gentle confidence.","zh-CN":"适合日常佩戴的轻精致珠宝。"}'::jsonb, 'active', 20)
ON CONFLICT (handle) DO NOTHING;

INSERT INTO products (
  handle,
  product_type,
  status,
  sku_prefix,
  shipping_profile_id,
  size_guide_id,
  gift_ready,
  gift_message_supported,
  is_personalizable,
  featured_score,
  display_order,
  admin_label,
  merch_notes
)
SELECT
  'luna-pearl-earrings',
  'earrings',
  'active',
  'SL-LUNA',
  sp.id,
  sg.id,
  TRUE,
  TRUE,
  FALSE,
  95,
  10,
  'Luna hero product',
  'Use for gift-friendly front-page placements'
FROM shipping_profiles sp
JOIN size_guides sg
  ON sg.handle = 'earring-core-fit'
WHERE sp.handle = 'au-ready'
ON CONFLICT (handle) DO NOTHING;

INSERT INTO product_content (
  product_id,
  locale,
  title,
  short_blurb,
  description_html,
  skin_friendly_note,
  seo_title,
  seo_description
)
SELECT
  p.id,
  content.locale,
  content.title,
  content.short_blurb,
  content.description_html,
  content.skin_friendly_note,
  content.seo_title,
  content.seo_description
FROM products p
JOIN (
  VALUES
    ('en-AU', 'Luna Pearl Earrings', 'Soft pearl drops for gifting and all-day wear.', '<p>Elegant freshwater pearl drops designed for thoughtful gifting and gentle daily polish.</p>', 'Sterling silver base designed with sensitive skin in mind.', 'Luna Pearl Earrings | Southern Light Jewellery', 'Gift-friendly pearl earrings with calm, polished everyday wear appeal.'),
    ('zh-CN', 'Luna 珍珠耳环', '柔和珍珠耳饰，适合送礼与日常佩戴。', '<p>淡水珍珠垂坠耳饰，兼顾送礼仪式感与日常轻精致气质。</p>', '925 银底材，更适合敏感肌日常佩戴。', 'Luna 珍珠耳环 | Southern Light Jewellery', '适合送礼与日常佩戴的珍珠耳环，气质柔和，易于搭配。')
) AS content(locale, title, short_blurb, description_html, skin_friendly_note, seo_title, seo_description)
  ON TRUE
WHERE p.handle = 'luna-pearl-earrings'
ON CONFLICT (product_id, locale) DO NOTHING;

INSERT INTO product_variants (
  product_id,
  sku,
  option1_name,
  option1_value,
  price,
  compare_at_price,
  cost_price,
  currency,
  weight_grams,
  inventory_quantity,
  reserved_quantity,
  reorder_point,
  is_default,
  is_active,
  sort_order
)
SELECT
  p.id,
  'SL-LUNA-PEARL-OS',
  'Size',
  'One size',
  149.00,
  179.00,
  58.00,
  'AUD',
  6.50,
  18,
  2,
  4,
  TRUE,
  TRUE,
  1
FROM products p
WHERE p.handle = 'luna-pearl-earrings'
ON CONFLICT (sku) DO NOTHING;

INSERT INTO product_media (
  product_id,
  media_type,
  source_url,
  alt_i18n,
  sort_order,
  is_primary,
  admin_note
)
SELECT
  p.id,
  'image',
  'https://cdn.example.com/jewelry/luna-pearl-earrings-main.jpg',
  '{"en-AU":"Luna Pearl Earrings on warm neutral background","zh-CN":"Luna 珍珠耳环主图"}'::jsonb,
  1,
  TRUE,
  'Replace with production CDN asset later'
FROM products p
WHERE p.handle = 'luna-pearl-earrings'
  AND NOT EXISTS (
    SELECT 1
    FROM product_media pm
    WHERE pm.product_id = p.id
      AND pm.sort_order = 1
  );

INSERT INTO product_collection_memberships (product_id, collection_id, sort_order)
SELECT p.id, c.id, 1
FROM products p
JOIN collections c
  ON c.handle = 'gift-edit'
WHERE p.handle = 'luna-pearl-earrings'
ON CONFLICT (product_id, collection_id) DO NOTHING;

INSERT INTO product_materials (
  product_id,
  material_id,
  role,
  is_primary,
  composition_percent,
  display_order,
  note_i18n
)
SELECT
  p.id,
  m.id,
  'base_metal',
  TRUE,
  100.00,
  1,
  '{"en-AU":"Sterling silver base beneath vermeil finish.","zh-CN":"925 银底材，表面覆 18K 镀金。"}'::jsonb
FROM products p
JOIN materials m
  ON m.handle = 'sterling-silver'
WHERE p.handle = 'luna-pearl-earrings'
ON CONFLICT (product_id, material_id, role) DO NOTHING;

INSERT INTO product_finishes (
  product_id,
  finish_id,
  is_primary,
  display_order,
  note_i18n
)
SELECT
  p.id,
  f.id,
  TRUE,
  1,
  '{"en-AU":"Warm vermeil finish for soft golden light.","zh-CN":"18K 镀金表面呈现柔和暖金光泽。"}'::jsonb
FROM products p
JOIN finishes f
  ON f.handle = '18k-gold-vermeil'
WHERE p.handle = 'luna-pearl-earrings'
ON CONFLICT (product_id, finish_id) DO NOTHING;

INSERT INTO product_gemstones (
  product_id,
  gemstone_id,
  role,
  is_primary,
  stone_count,
  display_order,
  note_i18n
)
SELECT
  p.id,
  g.id,
  'pearl',
  TRUE,
  2,
  1,
  '{"en-AU":"Matched pair of freshwater pearls.","zh-CN":"成对搭配的淡水珍珠。"}'::jsonb
FROM products p
JOIN gemstones g
  ON g.handle = 'freshwater-pearl'
WHERE p.handle = 'luna-pearl-earrings'
ON CONFLICT (product_id, gemstone_id, role) DO NOTHING;

INSERT INTO product_care_guides (product_id, care_guide_id, is_primary, display_order)
SELECT p.id, cg.id, (cg.handle = 'pearl-care'), CASE WHEN cg.handle = 'pearl-care' THEN 1 ELSE 2 END
FROM products p
JOIN care_guides cg
  ON cg.handle IN ('gold-vermeil-care', 'pearl-care')
WHERE p.handle = 'luna-pearl-earrings'
ON CONFLICT (product_id, care_guide_id) DO NOTHING;

INSERT INTO product_badges (product_id, badge_id, display_order)
SELECT p.id, b.id, badge_order.display_order
FROM products p
JOIN (
  VALUES
    ('gift_ready', 1),
    ('daily_layering', 2)
) AS badge_order(code, display_order)
  ON TRUE
JOIN badges b
  ON b.code::TEXT = badge_order.code
WHERE p.handle = 'luna-pearl-earrings'
ON CONFLICT (product_id, badge_id) DO NOTHING;

INSERT INTO customers (
  external_customer_ref,
  stage,
  email,
  phone,
  first_name,
  last_name,
  preferred_locale,
  preferred_currency,
  country_code,
  birth_month,
  marketing_consent_email,
  marketing_consent_sms,
  acquisition_source,
  admin_note
)
VALUES (
  'shopify-customer-1001',
  'client',
  'amelia.grant@example.com',
  '+61 412 555 888',
  'Amelia',
  'Grant',
  'en-AU',
  'AUD',
  'AU',
  9,
  TRUE,
  FALSE,
  'gift-guide',
  'Prefers light gold finishes and gift-ready packaging'
)
ON CONFLICT (email) DO NOTHING;

INSERT INTO customer_addresses (
  customer_id,
  label,
  recipient_name,
  phone,
  line1,
  city,
  state_region,
  postal_code,
  country_code,
  is_default_shipping,
  is_default_billing
)
SELECT
  c.id,
  'Home',
  'Amelia Grant',
  c.phone,
  '18 Hawthorne Street',
  'New Farm',
  'QLD',
  '4005',
  'AU',
  TRUE,
  TRUE
FROM customers c
WHERE c.email = 'amelia.grant@example.com'
  AND NOT EXISTS (
    SELECT 1
    FROM customer_addresses ca
    WHERE ca.customer_id = c.id
      AND ca.label = 'Home'
  );

INSERT INTO customer_profiles (
  customer_id,
  primary_intent,
  preferred_metal,
  preferred_stone,
  ring_size_label,
  sensitive_skin,
  style_keywords,
  gifting_notes,
  admin_note
)
SELECT
  c.id,
  'gift',
  'warm gold',
  'pearl',
  'US 6',
  TRUE,
  ARRAY['soft', 'minimal', 'giftable'],
  'Likes low-risk birthday gifts with elegant packaging.',
  'Strong fit for concierge gifting flows.'
FROM customers c
WHERE c.email = 'amelia.grant@example.com'
ON CONFLICT (customer_id) DO NOTHING;

INSERT INTO consultations (
  consultation_code,
  customer_id,
  consultation_type,
  status,
  intent,
  preferred_contact_channel,
  preferred_locale,
  budget_min,
  budget_max,
  currency,
  recipient_relation,
  occasion_name,
  occasion_date,
  requested_at,
  scheduled_for,
  brief_text,
  internal_notes,
  converted_product_id
)
SELECT
  'CONS-2026-0001',
  c.id,
  'gift_concierge',
  'qualified',
  'gift',
  'email',
  'en-AU',
  120.00,
  180.00,
  'AUD',
  'Sister',
  'Birthday',
  DATE '2026-05-10',
  NOW() - INTERVAL '3 days',
  NOW() + INTERVAL '1 day',
  'Looking for something refined, lightweight, and safe for sensitive ears.',
  'Prioritize pearl or soft gold gift options.',
  p.id
FROM customers c
JOIN products p
  ON p.handle = 'luna-pearl-earrings'
WHERE c.email = 'amelia.grant@example.com'
ON CONFLICT (consultation_code) DO NOTHING;

INSERT INTO consultation_recommendations (
  consultation_id,
  product_id,
  variant_id,
  rationale,
  sort_order,
  is_primary,
  selected
)
SELECT
  ct.id,
  p.id,
  pv.id,
  'Low sizing risk, soft pearl finish, and strong gift-ready presentation.',
  1,
  TRUE,
  TRUE
FROM consultations ct
JOIN products p
  ON p.handle = 'luna-pearl-earrings'
JOIN product_variants pv
  ON pv.product_id = p.id
 AND pv.is_default = TRUE
WHERE ct.consultation_code = 'CONS-2026-0001'
  AND NOT EXISTS (
    SELECT 1
    FROM consultation_recommendations cr
    WHERE cr.consultation_id = ct.id
      AND cr.product_id = p.id
  );

INSERT INTO jewelry_passports (
  passport_code,
  product_id,
  variant_id,
  owner_customer_id,
  purchaser_customer_id,
  external_order_ref,
  purchase_date,
  warranty_expires_on,
  status,
  care_plan_handle,
  last_service_at,
  internal_note
)
SELECT
  'PASS-2026-0001',
  p.id,
  pv.id,
  c.id,
  c.id,
  'SHOPIFY-ORDER-5001',
  DATE '2026-04-15',
  DATE '2027-04-15',
  'active',
  'pearl-care',
  NOW() - INTERVAL '14 days',
  'Registered from first gift concierge conversion.'
FROM customers c
JOIN products p
  ON p.handle = 'luna-pearl-earrings'
JOIN product_variants pv
  ON pv.product_id = p.id
 AND pv.is_default = TRUE
WHERE c.email = 'amelia.grant@example.com'
ON CONFLICT (passport_code) DO NOTHING;

INSERT INTO service_requests (
  service_code,
  customer_id,
  passport_id,
  product_id,
  variant_id,
  request_type,
  status,
  intake_channel,
  issue_summary,
  customer_note,
  admin_note,
  quoted_amount,
  quote_currency,
  approved_at,
  received_at,
  due_at
)
SELECT
  'SRV-2026-0001',
  c.id,
  jp.id,
  p.id,
  pv.id,
  'cleaning',
  'in_progress',
  'email',
  'Annual pearl cleaning and finish inspection.',
  'Customer wants the piece refreshed before gifting season.',
  'Bundle with pearl inspection and clasp check.',
  35.00,
  'AUD',
  NOW() - INTERVAL '5 days',
  NOW() - INTERVAL '3 days',
  NOW() + INTERVAL '4 days'
FROM customers c
JOIN jewelry_passports jp
  ON jp.passport_code = 'PASS-2026-0001'
JOIN products p
  ON p.id = jp.product_id
JOIN product_variants pv
  ON pv.id = jp.variant_id
WHERE c.email = 'amelia.grant@example.com'
ON CONFLICT (service_code) DO NOTHING;

INSERT INTO service_request_updates (
  service_request_id,
  status,
  public_message,
  internal_message,
  internal_only,
  created_by
)
SELECT
  sr.id,
  'in_progress',
  'Your piece is now being cleaned and inspected.',
  'Check pearl surface and vermeil wear before dispatch.',
  FALSE,
  'service-team'
FROM service_requests sr
WHERE sr.service_code = 'SRV-2026-0001'
  AND NOT EXISTS (
    SELECT 1
    FROM service_request_updates sru
    WHERE sru.service_request_id = sr.id
      AND sru.status = 'in_progress'
  );

INSERT INTO passport_events (
  passport_id,
  event_type,
  service_request_id,
  event_at,
  description,
  event_meta,
  created_by
)
SELECT
  jp.id,
  'service',
  sr.id,
  NOW() - INTERVAL '3 days',
  'Passport updated with annual cleaning request.',
  '{"service_stage":"inspection"}'::jsonb,
  'service-team'
FROM jewelry_passports jp
JOIN service_requests sr
  ON sr.passport_id = jp.id
WHERE jp.passport_code = 'PASS-2026-0001'
  AND NOT EXISTS (
    SELECT 1
    FROM passport_events pe
    WHERE pe.passport_id = jp.id
      AND pe.service_request_id = sr.id
  );
