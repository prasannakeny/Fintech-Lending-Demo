include: "*.view"

view: loan_sequence {
  extends: [loans]
  derived_table: {
    sql: select loans.*, rank() over (partition by disp_id order by acc_open_date) as rank
    from `fintech-demo-prasanna-386521.loans.loans` as loans;;
   # sql_trigger_value: select max(acc_open_date) from `pkeny-primary.loans.loans`;;
  }



  dimension: type {
    label: "Loan Type"
    type: string
    sql: ${TABLE}.type ;;
    }

  dimension: disp_id {
    hidden: yes
    sql: ${TABLE}.disp_id ;;
  }

  dimension: customer_loan_sequence {
    label: "Customer Loan Sequence"
    type: number
    description: "The order in which loan accounts were opened"
    sql: ${TABLE}.rank ;;
  }

  dimension: is_first_loan {
    label: "Is First Loan"
    type: yesno
    description: "Is this loan the client's first from us?"
    sql: ${customer_loan_sequence} = 1 ;;
  }

}


#  dimension: months_between_signup {
#    label: "Months Between Signup"
#    description: "The days between signing up for the first card and signing up for the next card"
#    type: duration_month
#    sql_start:  ${card_order_sequence.create_raw};;
#    sql_end:  ${repeat_card_purchase.create_raw};;
#  }
