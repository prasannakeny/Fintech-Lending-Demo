# The name of this view in Looker is "Loans"
view: loans {
  sql_table_name: `loans.loans`
    ;;
  drill_fields: [loan_id]
  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: loan_id {
    label: "Loan ID"
    primary_key: yes
    type: number
    sql: ${TABLE}.loan_id ;;
    value_format_name: id
    action: {
      label: "Send Financial Advice Letter"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://sendgrid.com/favicon.ico"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
    }
    action: {
      label: "Send Welcome Offers"
      url: "https://desolate-refuge-53336.herokuapp.com/posts"
      icon_url: "https://sendgrid.com/favicon.ico"
      param: {
        name: "some_auth_code"
        value: "abc123456"
      }
    }
  }

  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: acc_open {
    label: "Account Opening"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.acc_open_date ;;
  }


  dimension_group: acc_closure {
    label: "Account Closure"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.acc_closure_date ;;
  }

  dimension: loan_acc_number {
    type: number
    sql: ${TABLE}.loan_acc_number ;;
  }

  dimension: is_closed {
    label: "Is Closed (y/n)"
    description: "Was the loan closed or not?"
    type: yesno
    sql: ${acc_closure_date} is not null;;
  }


  dimension: months_since_opened {
    label: "Months Active"
    description: "Months that the card has been, or was (if canceled), active for"
    type: duration_month
    sql_start: ${acc_open_date} ;;
    sql_end: case when ${acc_closure_date} is not null then ${acc_closure_date} else current_timestamp() end ;;
  }

  dimension: months_as_customer_tiered {
    label: "Months Active Tiered"
    type: tier
    style: integer
    tiers: [1,3,6,12,24]
    sql: ${months_since_opened} ;;
  }

  # Here's what a typical dimension looks like in LookML.
  # A dimension is a groupable field that can be used to filter query results.
  # This dimension will be called "Disp ID" in Explore.

  dimension: disp_id {
    hidden: yes
    type: number
    sql: ${TABLE}.disp_id ;;
    value_format_name: id
  }

  dimension: duration_months {
    label: "Loan Tenure (months)"
    type: number
    sql: ${TABLE}.duration_months ;;
  }

  # A measure is a field that uses a SQL aggregate function. Here are defined sum and average
  # measures for this dimension, but you can also add measures of many different aggregates.
  # Click on the type parameter to see all the options in the Quick Help panel on the right.


  measure: average_duration_months {
    label: "Average Tenure (months)"
    type: average
    sql: ${duration_months} ;;
  }

  dimension: index {
    hidden: yes
    type: number
    sql: ${TABLE}.index ;;
  }

  dimension: interest_rate {
    label: "Interest Rate"
    type: number
    sql: ${TABLE}.interest_rate ;;
  }



  dimension: outstanding {
    label: "Outstanding Amount"
    type: number
    sql: ${TABLE}.outstanding ;;
  }

  dimension: principal {
    label: "Principal Amount"
    type: number
    sql: ${TABLE}.principal_ ;;
  }

  dimension: type {
    label: "Loan A/c Type"
    type: string
    sql: ${TABLE}.type ;;
  }

  measure: number_of_loan_accs {
    label: "Number of Loan Accounts"
    type: count
    drill_fields: [type, loan_id, principal, duration_months]
  }

  measure: total_outstanding {
    label: "Total Outstanding"
    type: sum
    sql: ${outstanding} ;;
    drill_fields: [type]
    value_format_name: decimal_2
  }

  measure: total_loan_amt {
    label: "Total Loan Amount"
    type: sum
    sql: ${principal} ;;
    drill_fields: [type]
    value_format_name: decimal_2
  }

}
