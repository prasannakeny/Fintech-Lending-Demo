# The name of this view in Looker is "Customer Attributes"
view: customer_attributes {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `loans.customer_attributes`
    ;;

  dimension: churn_score {
    label: "Churn Score"
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.churn_score ;;
  }


  measure: average_churn_score {
    label: "Average Churn Score"
    type: average
    value_format_name: decimal_2
    sql: ${churn_score} ;;
  }

  dimension: client_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.client_id ;;
    link: {
      label: "Customer Account Overview"
      url: "https://googlecloud.looker.com/dashboards/1835?Client+ID={{ value | encode_uri }}"
      icon_url: "https://www.looker.com/static/assets/favicons/favicon-32x32.png"
    }
    action: {
      label: "Send Retention Offer"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://sendgrid.com/favicon.ico"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
    }
  }



  dimension: cltv {
    label: "CLTV"
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.cltv ;;
  }

  dimension: next_best_offer {
    label: "Next Best Offer"
    type: string
    sql: ${TABLE}.next_best_offer ;;
  }

  dimension: next_best_product {
    label: "Next Best Product"
    type: string
    sql: ${TABLE}.next_best_product ;;
  }

  dimension: nps_score {
    label: "NPS Score"
    type: number
    sql: ${TABLE}.nps_score ;;
  }

  dimension: offer_propensity {
    label: "Offer Propensity"
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.offer_propensity ;;
  }

  dimension: product_propensity {
    label: "Product Propensity"
    type: number
    value_format_name: decimal_2
    sql: ${TABLE}.product_propensity ;;
  }

  dimension: segment {
    hidden: yes
    label: "Customer Segment"
    type: string
    sql: ${TABLE}.segment ;;
  }

  measure: count {
    type: count
    drill_fields: [client_id, segment, cltv, churn_score, next_best_offer, offer_propensity]
  }
}
