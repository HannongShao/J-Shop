# 珠宝网站代码写作方案

## 结论先说

基于上一份网页制作规划，这个项目第一阶段最合理的代码路线不是直接做 headless，也不是先上一个重前端框架，而是：

`Shopify Online Store 2.0 自定义主题 + Dawn 作为参考底座 + Liquid/JSON templates/Sections/Blocks + 少量原生 JavaScript 增强`

原因很简单：

- 你的当前目标是尽快上线一个“澳洲优先、中文可用”的中端珠宝品牌站。
- 第一阶段最大的风险不是“前端不够先进”，而是“品牌表达、产品页信息、双语、本地化和转化细节没有做对”。
- Shopify 主题架构已经天然包含产品、购物车、结账、市场、语言、支付、SEO、主题编辑器这些核心能力。
- Dawn 的官方方向本身就是 `HTML-first`、`JavaScript only as needed`、`server-rendered`，很适合珠宝这种强视觉、重 SEO、重性能的电商场景。

所以，这份代码方案的核心思想是：

`先写一套结构清晰、内容可配置、国际化友好的 Shopify 主题工程；以后如果品牌内容和交互复杂度继续升级，再评估 headless。`

## 一、技术路线选择

### 1. 第一阶段推荐方案

推荐技术栈：

- 平台：`Shopify`
- 主题架构：`Online Store 2.0`
- 代码主体：`Liquid + JSON templates + schema + snippets + assets`
- 样式：`CSS`
- 交互：`原生 JavaScript / Web Components 风格的最小增强`
- 本地化：`Shopify Markets + locale files + Shopify 后台翻译内容`

### 2. 为什么这次不建议直接 headless

这次项目如果一开始就上 `Next.js + Storefront API`，你会得到更多自由度，但也会立刻增加下面这些复杂度：

- 商品数据查询与缓存策略
- 购物车状态管理
- 国际化路由与价格显示逻辑
- 主题后台可编辑性明显下降
- 内容团队对页面的可配置能力变弱
- 开发、部署、维护和 SEO 验证成本都更高

而你的第一阶段目标更需要的是：

- 快速验证产品与视觉是否成立
- 快速优化首页与产品页转化
- 快速调整中文页面和配送/退换信息

因此代码路线要服务业务验证，而不是反过来。

### 3. 第二阶段再考虑 headless 的触发条件

只有在下面这些情况明显出现时，才建议升级：

- 你需要非常复杂的品牌叙事页面和交互动效
- 你要做搭配推荐、个性化测验、复杂 bundle
- 你要把内容系统、会员系统、CRM 深度打通
- 你需要多个前端渠道共用一套 commerce API

在此之前，主题工程就够用，而且更稳。

## 二、代码目标

这套代码不是“能跑起来”就行，而是要满足 6 个目标：

1. 页面能快速上线并持续迭代。
2. 首页、分类页、产品页、品牌页都可以由后台灵活配置。
3. 主题文案和 UI 组件天然支持英文与简体中文。
4. 产品页能承载珠宝特有的信息密度：材质、尺寸、佩戴、配送、退换、FAQ。
5. JS 尽量轻，页面主要依赖服务端渲染输出。
6. 目录、命名和模块拆分足够清晰，后续加人开发不会乱。

## 三、工程结构设计

### 1. 推荐目录结构

以 Dawn 为参考底座后，建议最终项目保持下面这个结构：

```text
theme/
├── assets/
│   ├── base.css
│   ├── tokens.css
│   ├── section-hero.css
│   ├── section-trust-bar.css
│   ├── section-featured-collections.css
│   ├── section-product-details.css
│   ├── component-product-card.css
│   ├── component-accordion.css
│   ├── component-badge.css
│   ├── global.js
│   ├── product-form.js
│   ├── product-gallery.js
│   ├── sticky-atc.js
│   ├── predictive-search.js
│   └── locale-switcher.js
├── blocks/
│   ├── rich-text.liquid
│   ├── trust-item.liquid
│   ├── feature-card.liquid
│   ├── icon-text.liquid
│   └── review-quote.liquid
├── config/
│   ├── settings_data.json
│   └── settings_schema.json
├── layout/
│   └── theme.liquid
├── locales/
│   ├── en.default.json
│   ├── zh-CN.json
│   ├── en.default.schema.json
│   └── zh-CN.schema.json
├── sections/
│   ├── announcement-bar.liquid
│   ├── header.liquid
│   ├── footer.liquid
│   ├── hero-editorial.liquid
│   ├── trust-bar.liquid
│   ├── featured-collections.liquid
│   ├── featured-products.liquid
│   ├── gift-guide-grid.liquid
│   ├── material-story.liquid
│   ├── review-strip.liquid
│   ├── image-text-editorial.liquid
│   ├── newsletter-signup.liquid
│   ├── main-collection-banner.liquid
│   ├── main-collection-product-grid.liquid
│   ├── main-product.liquid
│   ├── product-complements.liquid
│   ├── faq-list.liquid
│   ├── contact-panel.liquid
│   └── main-page.liquid
├── snippets/
│   ├── price.liquid
│   ├── product-card.liquid
│   ├── product-badges.liquid
│   ├── product-materials.liquid
│   ├── product-size-guide.liquid
│   ├── product-shipping-note.liquid
│   ├── product-care-note.liquid
│   ├── product-accordion-item.liquid
│   ├── icon.liquid
│   ├── button.liquid
│   ├── locale-switcher.liquid
│   ├── market-switcher.liquid
│   ├── social-proof-item.liquid
│   └── seo-tags.liquid
├── templates/
│   ├── index.json
│   ├── collection.json
│   ├── product.json
│   ├── page.about.json
│   ├── page.gift-guide.json
│   ├── page.materials.json
│   ├── page.size-guide.json
│   ├── page.contact.json
│   └── search.json
└── templates/customers/
```

### 2. 目录设计原则

- `sections/` 放页面级可编排模块。
- `blocks/` 放可复用的 Theme Blocks。
- `snippets/` 放细粒度逻辑片段和共享组件。
- `assets/` 放样式和前端增强脚本。
- `locales/` 放界面级翻译，不放商品内容翻译。
- `templates/` 只做页面装配，不堆复杂逻辑。

## 四、模块拆分方案

### 1. 页面级模块

你这个珠宝站第一阶段建议拆成 4 类页面模块。

#### A. 全站结构模块

- `header.liquid`
- `announcement-bar.liquid`
- `footer.liquid`
- `locale-switcher.liquid`
- `market-switcher.liquid`

职责：

- 导航
- 语言/市场切换
- 购物车入口
- 顶部品牌承诺信息
- 页脚政策与客服入口

#### B. 首页内容模块

- `hero-editorial.liquid`
- `trust-bar.liquid`
- `featured-collections.liquid`
- `featured-products.liquid`
- `gift-guide-grid.liquid`
- `material-story.liquid`
- `review-strip.liquid`
- `newsletter-signup.liquid`

职责：

- 建立第一印象
- 引导用户快速进入“畅销”“礼物”“材质”“场景”
- 增加社交证明与品牌可信度

#### C. 列表与搜索模块

- `main-collection-banner.liquid`
- `main-collection-product-grid.liquid`
- `predictive-search.js`

职责：

- 分类页视觉统一
- 产品卡片布局
- 筛选、排序、分页
- 搜索词建议

#### D. 产品转化模块

- `main-product.liquid`
- `product-complements.liquid`
- `product-materials.liquid`
- `product-size-guide.liquid`
- `product-shipping-note.liquid`
- `product-care-note.liquid`
- `product-accordion-item.liquid`

职责：

- 处理珠宝产品页的所有高价值信息
- 降低尺寸、材质、配送不确定性
- 提高加购与连带销售

### 2. 组件级模块

建议统一做成 snippets，避免各 section 自己复制一遍：

- `product-card.liquid`
- `price.liquid`
- `button.liquid`
- `icon.liquid`
- `product-badges.liquid`
- `social-proof-item.liquid`
- `seo-tags.liquid`

### 3. 为什么这样拆

这套拆法有 3 个优点：

- 商业上对齐：围绕“首页表达”和“产品页转化”来组织代码。
- 技术上稳定：大部分内容都能在主题编辑器里配置。
- 后期扩展容易：换首页模块、加礼物模块、加中文提示都不会打散现有结构。

## 五、数据建模方案

珠宝网站最怕内容写死在模板里。正确的做法不是把所有信息直接硬编码到产品描述里，而是把高频结构化信息拆出来。

### 1. 用 metafields 存“产品属性”

适合放在 `product` 维度上的内容：

- 材质说明
- 镀层说明
- 宝石类型
- 是否敏感肌友好
- 保养摘要
- 发货提示
- 是否可礼盒包装
- 戒围说明
- 系列副标题

推荐字段思路：

```text
product.metafields.custom.short_blurb
product.metafields.custom.material_primary
product.metafields.custom.plating_info
product.metafields.custom.gemstone_type
product.metafields.custom.skin_friendly_note
product.metafields.custom.shipping_note
product.metafields.custom.care_summary
product.metafields.custom.gift_ready
product.metafields.custom.size_chart
product.metafields.custom.related_story
```

### 2. 用 metaobjects 存“可复用内容对象”

适合做成 metaobjects 的内容：

- 尺寸指南
- 材质指南
- 保养指南
- FAQ 项
- 礼物专题卡片
- 信任卖点
- 首页评价引言

推荐定义：

```text
size_chart
material_guide
care_guide
faq_item
trust_badge
gift_guide_card
review_quote
```

### 3. 为什么要这样建模

Shopify 官方文档对 metafields 和 metaobjects 的定位非常清楚：

- `metafields` 适合给标准资源补字段
- `metaobjects` 适合创建独立可复用的数据对象

对你的项目来说，这能直接带来几个好处：

- 产品页模板不需要写死大量说明文字
- 英文和中文内容更容易统一维护
- 后续换页面布局时，不需要重录一遍内容
- 尺寸指南、材质指南、FAQ 可以复用到多个页面

## 六、本地化代码方案

### 1. 双语策略

这个项目建议把本地化分成两层：

#### 第一层：主题 UI 文案

放在 `locales/`：

- 导航
- 按钮
- 表单提示
- 加购提示
- 配送摘要标签
- FAQ 标题
- 通用组件文案

例如：

```json
{
  "products": {
    "product": {
      "add_to_cart": "Add to cart",
      "materials": "Materials",
      "shipping_returns": "Shipping & Returns"
    }
  }
}
```

#### 第二层：业务内容翻译

交给 Shopify 后台内容翻译：

- 产品标题
- 产品描述
- Collection 文案
- Page 内容
- Blog / Journal 内容
- Metaobject 内容

### 2. 代码层本地化要求

必须遵守：

- 不要把英文按钮文案硬编码在 section/snippet 里
- 所有 UI 固定文案都走 translation key
- 所有货币显示都使用 Shopify 的 money 过滤器或平台提供格式化
- 不在前端 JS 里自己拼接货币和价格字符串

### 3. URL 与市场策略

代码上默认支持：

- `en-AU` 为主
- `zh-CN` 为辅

推荐形态：

- 主站 `example.com`
- 中文 `example.com/zh-cn`

如果后续启用国际域名或单独市场域名，代码仍然不需要大改，因为 Markets 和本地化路由由 Shopify 侧承接。

## 七、样式写作方案

### 1. 样式原则

建议采用“设计令牌 + 组件样式 + section 样式”的结构。

### 2. CSS 层次

```text
tokens.css
base.css
component-*.css
section-*.css
```

职责：

- `tokens.css`：颜色、间距、字体、阴影、圆角、容器宽度
- `base.css`：reset、排版、通用布局
- `component-*.css`：按钮、卡片、徽章、accordion、drawer
- `section-*.css`：首页 hero、trust bar、gift guide 等模块专属样式

### 3. CSS 写法建议

- 用 CSS Custom Properties 管理主题变量
- 优先移动端，再向上增强
- 避免写大量页面级覆盖选择器
- 控制选择器层级，尽量 2 到 3 层以内
- 避免把视觉逻辑散落在 Liquid 模板内联样式里

### 4. 视觉变量建议

```css
:root {
  --color-bg: #f6f1ea;
  --color-surface: #fffdf9;
  --color-text: #2f2b28;
  --color-muted: #736b63;
  --color-accent: #b49362;
  --color-soft: #d8d1c5;
  --font-heading: "Cormorant Garamond", serif;
  --font-body: "Helvetica Neue", Arial, sans-serif;
  --container-max: 1240px;
  --space-2: 0.5rem;
  --space-4: 1rem;
  --space-8: 2rem;
}
```

上面的变量只是方向示例，后面可以继续细化。

## 八、JavaScript 写作方案

### 1. 原则

这类站点不要走“大量前端状态管理”的路线。

JS 只做增强，不做页面主体依赖。

建议只保留下面几类 JS：

- Header 抽屉菜单
- Predictive Search
- Product Gallery
- Sticky Add to Cart
- 轻量 Accordion
- Locale/market switch interaction

### 2. JS 代码组织

建议写成独立模块文件：

```text
assets/global.js
assets/product-gallery.js
assets/product-form.js
assets/sticky-atc.js
assets/predictive-search.js
assets/locale-switcher.js
```

### 3. JS 编写要求

- 每个模块只负责一类行为
- 通过 `data-*` 属性挂载，不直接依赖脆弱的 DOM 结构
- 所有关键交互都要有“无 JS 时的基础可用方案”
- 不引入大型前端依赖，仅为了一两个交互动效

### 4. 交互优先级

先写：

- 移动端菜单
- 产品图切换
- Sticky Add to Cart
- Accordion

后写：

- Predictive Search
- 微动画
- 图片懒加载细节优化

## 九、页面开发顺序

建议严格按转化价值排序，不要先做很多边缘页。

### Phase 1：工程底座

先完成：

- 初始化主题工程
- 基础目录
- 主题设置项
- 色彩和字体变量
- Header / Footer / Announcement Bar
- locales 文件

交付标准：

- 能跑 development theme
- 全站有统一头尾结构
- 中英文 UI 文案可以切换

### Phase 2：首页系统

再完成：

- Hero
- Trust Bar
- Featured Collections
- Featured Products
- Gift Guide Grid
- Material Story
- Newsletter

交付标准：

- 首页模块都能在编辑器中拖拽和配置
- 无需改代码即可调整顺序和文案

### Phase 3：分类页与搜索

再完成：

- Collection Banner
- Product Grid
- Filter / Sort
- Predictive Search

交付标准：

- 用户能顺畅筛选和浏览
- 列表页移动端不卡顿

### Phase 4：产品页转化系统

这是最重要的一期：

- 产品图库
- 价格与库存区
- 材质说明
- 尺寸指南
- 配送与退换摘要
- FAQ accordion
- 搭配推荐
- Sticky Add to Cart

交付标准：

- 产品页信息密度完整但不臃肿
- 移动端购买动作始终可达

### Phase 5：内容页与合规页

再完成：

- About
- Materials
- Size Guide
- Contact
- Shipping & Returns
- Privacy / Terms / Refund

交付标准：

- 可直接用于正式上线
- 中文内容也能完整承接

### Phase 6：优化与埋点

最后做：

- SEO 标签
- 商品结构化数据
- 性能优化
- 分析埋点
- 主题检查和回归测试

## 十、关键 section 的代码设计

### 1. 首页 Hero

建议 schema 支持：

- 主标题
- 副标题
- 主图 / 移动图
- 两个 CTA
- 文本位置
- 颜色方案
- 可选 trust note

不要在 Hero 里塞太多逻辑，它的职责就是建立品牌印象和给出第一个入口。

### 2. Trust Bar

建议支持 3 到 4 个 block：

- Free shipping threshold
- Gift-ready packaging
- Material transparency
- Easy returns / local service

这类信息非常适合 block 化，因为未来你会频繁改文案。

### 3. Product Main

建议拆成几个子 snippet：

- media gallery
- product info header
- variant picker
- pricing
- badges
- accordions
- sticky add to cart

原因是产品页后续迭代最多，必须避免一个 `main-product.liquid` 写成超级大文件。

### 4. FAQ / Guide 模块

建议直接读取 metaobjects 或 page 内容，而不是写死在 section schema 中。

因为：

- FAQ 会频繁改
- 中英文需要分别维护
- 尺寸指南和材质指南会跨页面复用

## 十一、编码规范

### 1. Liquid 规范

- 一个 section 只负责一个主职责
- 复杂判断尽量拆到 snippet
- 逻辑尽量清晰，不写过深嵌套
- 避免在模板里复制重复 HTML
- 对可为空的数据先判断再渲染

### 2. 命名规范

- section 文件名：`kebab-case`
- snippet 文件名：`kebab-case`
- CSS 类名：`component-name__part` 或清晰语义类名
- translation key：按功能域分组

### 3. 文案规范

- 所有固定 UI 文案走 locales
- 内容类文案不写死在模板
- 政策类文本优先来自 page / metaobject

### 4. 性能规范

- 图片使用 Shopify image filters 输出不同尺寸
- 首屏图单独优化
- 延迟加载次要图片
- 不为了简单动画引入大体积库
- 避免在 collection/product 页堆过多同步 JS

## 十二、质量保障方案

### 1. 本地开发工具

建议开发流程围绕 Shopify CLI：

- `shopify theme init`
- `shopify theme dev`
- `shopify theme check`
- `shopify theme profile`
- `shopify theme push`

Shopify 官方 CLI 文档已经覆盖这些主题开发命令。

### 2. 必做检查

每次迭代至少检查：

- Home
- Collection
- Product
- Cart
- Search
- Mobile menu
- Language switch
- 市场切换

### 3. 自动化建议

如果后续接入 GitHub Actions，建议最少做：

- Theme Check
- Lighthouse 基础性能检查

Dawn 官方仓库本身就是这样推荐的。

## 十三、建议的开发里程碑

### 里程碑 1：可运行主题底座

输出：

- Dawn 派生主题
- Header / Footer / tokens
- 基础 locales

### 里程碑 2：首页可视化完成

输出：

- 首页所有核心 section
- 主题编辑器可配置

### 里程碑 3：分类页与产品页完成

输出：

- Collection 浏览体验
- 完整 PDP
- sticky add to cart

### 里程碑 4：双语和内容页完成

输出：

- `en-AU`
- `zh-CN`
- 政策页与联系页

### 里程碑 5：上线前 QA

输出：

- Theme Check 通过
- 基本性能达标
- 核心页面无明显断点问题

## 十四、如果我来继续写代码，建议的第一步

如果下一步直接进入开发，我建议按这个顺序开始：

1. 初始化 Shopify 主题工程
2. 建立 `tokens.css`、`base.css`、`theme.liquid`
3. 先写 Header / Footer / Announcement Bar
4. 建首页 Hero、Trust Bar、Featured Products
5. 再写 Product Card 和 Product Main
6. 最后接双语、内容模型和合规页面

原因是：

- 这样最早能看到品牌站雏形
- 这样最早能验证视觉方向对不对
- 这样不会一开始就陷在产品页细节里

## 十五、这份代码方案的最终判断

对你这个项目来说，最好的代码方案不是“技术上最前沿”，而是“商业上最对路，工程上最稳，后期也能扩”。

所以我最终建议你把第一阶段代码策略定成：

`以 Shopify 主题为主战场，用 Dawn 的 HTML-first 和性能优先思路打底，用 metafields/metaobjects 解决珠宝信息结构化，用 locales + Markets 做好澳洲英文主站与简体中文辅助市场。`

这会比一开始就冲 headless 更适合你当前的品牌阶段。

## 参考依据

- Shopify Theme architecture  
  https://shopify.dev/docs/storefronts/themes/architecture
- Shopify Sections  
  https://shopify.dev/docs/storefronts/themes/architecture/sections
- Shopify Theme blocks  
  https://shopify.dev/docs/storefronts/themes/architecture/blocks
- Shopify Locales  
  https://shopify.dev/docs/storefronts/themes/architecture/locales/index
- Shopify CLI theme commands  
  https://shopify.dev/docs/api/shopify-cli/theme
- Shopify CLI for themes  
  https://shopify.dev/docs/storefronts/themes/tools/cli
- Shopify metafields and metaobjects  
  https://shopify.dev/docs/apps/build/custom-data/metafields
- Shopify data modeling with metafields and metaobjects  
  https://shopify.dev/docs/apps/build/metaobjects/data-modeling-with-metafields-and-metaobjects
- Shopify Help: manage languages for markets  
  https://help.shopify.com/en/manual/markets/languages/manage-languages
- Shopify Help: international domains  
  https://help.shopify.com/en/manual/international/managing-international-domains
- Dawn reference theme  
  https://github.com/Shopify/dawn

其中“先主题、后 headless”“把珠宝高频内容拆成 metafields/metaobjects”“先做产品页与首页模块，再做复杂内容页”等内容，是我结合上一份商业规划和以上官方资料做出的实施判断。
