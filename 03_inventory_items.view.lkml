view: inventory_items {
  sql_table_name: ecomm.inventory_items ;;
  ## DIMENSIONS ##

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: cost {
    type: number
    value_format: "$#,##0.00"
    sql: ${TABLE}.cost ;;
  }

  dimension_group: created {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: dateadd(d,1,${TABLE}.created_at);;
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
  }

  dimension_group: sold {
    type: time
    timeframes: [time, date, week, month, raw]
    sql: dateadd(d,1,${TABLE}.sold_at) ;;
  }

  dimension: is_sold {
    type: yesno
    sql: ${sold_raw} is not null ;;
  }

  dimension: days_in_inventory {
    description: "days between created and sold date"
    type: number
    sql: DATEDIFF('day', ${created_raw}, coalesce(${sold_raw},current_date())) ;;
  }

  dimension: days_in_inventory_tier {
    type: tier
    sql: ${days_in_inventory} ;;
    style: integer
    tiers: [
      0,
      5,
      10,
      20,
      40,
      80,
      160,
      360
    ]
  }

  dimension: days_since_arrival {
    description: "days since created - useful when filtering on sold yesno for items still in inventory"
    type: number
    sql: DATEDIFF('day', ${created_date}, current_date())) ;;
  }

  dimension: days_since_arrival_tier {
    type: tier
    sql: ${days_since_arrival} ;;
    style: integer
    tiers: [
      0,
      5,
      10,
      20,
      40,
      80,
      160,
      360
    ]
  }

  dimension: product_distribution_center_id {
    hidden: yes
    sql: ${TABLE}.product_distribution_center_id ;;
  }

  ## MEASURES ##

  measure: sold_count {
    type: count

    filters: {
      field: is_sold
      value: "Yes"
    }
  }

  measure: sold_percent {
    type: number
    value_format: "#.0\%"
    sql: 100.0 * ${sold_count}/NULLIF(${count},0) ;;
  }

  measure: total_cost {
    type: sum
    value_format_name: big_money
    sql: ${cost} ;;
  }

  measure: average_cost {
    type: average
    value_format: "$#,##0.00"
    sql: ${cost} ;;
  }

  measure: count {
    type: count
  }

  measure: number_on_hand {
    type: number
    sql: ${count} - ${sold_count} ;;
  }

  set: detail {
    fields: [
      id,
      products.item_name,
      products.category,
      products.brand,
      products.department,
      cost,
      created_time,
      sold_time
    ]
  }

  set: simple {
    fields: [
      id,
      cost,
      created_time,
      sold_time,
      count,
      total_cost,
      average_cost
    ]
  }
}
