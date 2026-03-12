# 풀무원 dbt 프로젝트 - Demo 시나리오

## 프로젝트 구조

```
dbt_project/
├── models/
│   ├── staging/          # 8개 스테이징 모델
│   │   ├── stg_customers.sql
│   │   ├── stg_suppliers.sql
│   │   ├── stg_raw_materials.sql
│   │   ├── stg_products.sql
│   │   ├── stg_production_orders.sql
│   │   ├── stg_quality_inspections.sql
│   │   ├── stg_inventory_transactions.sql
│   │   └── stg_sales_orders.sql
│   │
│   ├── intermediate/     # 3개 중간 변환 모델
│   │   ├── int_sales_enriched.sql
│   │   ├── int_production_with_quality.sql
│   │   └── int_inventory_daily_snapshot.sql
│   │
│   └── marts/            # 5개 분석 마트
│       ├── mart_sales_performance.sql
│       ├── mart_production_efficiency.sql
│       ├── mart_inventory_turnover.sql
│       ├── mart_supplier_scorecard.sql
│       └── mart_quality_dashboard.sql
│
├── macros/
│   └── generate_schema_name.sql
│
└── dbt_project.yml
```

## 데이터 파이프라인

### Stage 1: Staging Layer (8개 모델)
소스 테이블을 1:1로 매핑하고 컬럼명을 정규화합니다.

| 모델 | 소스 테이블 | 설명 |
|------|-----------|------|
| stg_customers | CUSTOMERS | 고객/거래처 |
| stg_suppliers | SUPPLIERS | 공급업체 |
| stg_raw_materials | RAW_MATERIALS | 원재료 |
| stg_products | PRODUCTS | 제품 마스터 |
| stg_production_orders | PRODUCTION_ORDERS | 생산 실적 |
| stg_quality_inspections | QUALITY_INSPECTIONS | 품질 검사 |
| stg_inventory_transactions | INVENTORY_TRANSACTIONS | 재고 거래 |
| stg_sales_orders | SALES_ORDERS | 판매 주문 |

### Stage 2: Intermediate Layer (3개 모델)
여러 소스를 조인하고 비즈니스 로직을 적용합니다.

| 모델 | 사용 소스 | 설명 |
|------|----------|------|
| int_sales_enriched | stg_sales_orders + stg_products + stg_customers | 판매 데이터 + 제품/고객 정보 + 마진 계산 |
| int_production_with_quality | stg_production_orders + stg_quality_inspections | 생산 + 품질 검사 결과 집계 |
| int_inventory_daily_snapshot | stg_inventory_transactions | 일별 재고 스냅샷 + 누적 잔고 |

### Stage 3: Marts Layer (5개 모델)
최종 분석용 마트를 생성합니다.

| 마트 | 소스 테이블 수 | 주요 지표 |
|------|-------------|----------|
| **mart_sales_performance** | 5개 (sales, products, customers + 2 intermediate) | 매출, 마진, 채널별/지역별 분석 |
| **mart_production_efficiency** | 5개 (production, quality, products + 2 intermediate) | 생산량, 불량률, 달성률, 원가 |
| **mart_inventory_turnover** | 5개 (inventory, products + raw_materials via lookup) | 재고회전율, DOH, 입출고 |
| **mart_supplier_scorecard** | 5개 (suppliers, raw_materials, production) | 공급업체 등급, 품질, 리드타임 |
| **mart_quality_dashboard** | 5개 (quality, production, products) | 합격률, 불량유형, 품질등급 |

## Demo 시나리오

### 시나리오 1: dbt 프로젝트 빌드
```bash
# 전체 빌드
dbt run

# Staging만 빌드
dbt run --select staging

# 특정 마트만 빌드
dbt run --select mart_sales_performance

# 의존성 포함 빌드
dbt run --select +mart_sales_performance
```

### 시나리오 2: 데이터 리니지 확인
```bash
# 모델 리니지 확인
dbt docs generate
dbt docs serve

# mart_sales_performance의 의존성:
# stg_sales_orders → int_sales_enriched → mart_sales_performance
# stg_products →        ↑
# stg_customers →       ↑
```

### 시나리오 3: 데이터 테스트
```bash
# 전체 테스트
dbt test

# 특정 모델 테스트
dbt test --select stg_customers
```

### 시나리오 4: Incremental 모델 (Production 적용)
대용량 데이터의 경우 incremental 전략으로 성능 최적화:
```sql
{{
    config(
        materialized='incremental',
        unique_key='order_id'
    )
}}
...
{% if is_incremental() %}
where order_date > (select max(order_date) from {{ this }})
{% endif %}
```

## 비즈니스 활용 사례

### 1. 판매 분석 (mart_sales_performance)
- 채널별 매출 비교 (RETAIL vs ONLINE vs WHOLESALE)
- 지역별 매출 현황
- 고객 등급별 매출 기여도
- 제품 카테고리별 마진 분석

### 2. 생산 효율 분석 (mart_production_efficiency)
- 공장별/라인별 생산성 비교
- 불량률 트렌드 모니터링
- 원가 구성 분석 (재료비/인건비/간접비)
- 계획 대비 실적 달성률

### 3. 재고 관리 (mart_inventory_turnover)
- 재고 회전율 분석
- 창고별 재고 현황
- 적정 재고 수준 모니터링
- 유통기한 임박 제품 관리

### 4. 공급업체 관리 (mart_supplier_scorecard)
- 공급업체 등급 평가
- 품질/납기 성과 분석
- 인증 현황 관리

### 5. 품질 대시보드 (mart_quality_dashboard)
- 검사 합격률 트렌드
- 불량 유형별 분석
- 제품군별 품질 현황
- 품질 등급 분류

## 실행 명령어

```bash
# 프로젝트 디렉토리 이동
cd /Users/jhong/pulmuone_poc/dbt_project

# 의존성 확인
dbt deps

# 전체 빌드
dbt run

# 테스트 실행
dbt test

# 문서 생성
dbt docs generate
dbt docs serve
```
