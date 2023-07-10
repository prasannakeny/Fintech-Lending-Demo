
connection: "fintech-lending"

include: "/views/**/*.view"


# Datagroups define a caching policy for an Explore. To learn more,
# use the Quick Help panel on the right to see documentation.

datagroup: fintech-lending_default_datagroup {
  # sql_trigger: SELECT MAX(id) FROM etl_log;;
  max_cache_age: "1 hour"
}

persist_with: fintech-lending_default_datagroup


explore: customers {
  label: "Lending - Business Overview"

  join: loans {
    relationship: one_to_many
    sql_on: ${customers.disp_id} = ${loans.disp_id};;
  }

  join: customer_attributes {
    relationship: one_to_one
    sql_on: ${customer_attributes.client_id} = ${customers.client_id} ;;
  }
}

explore: loan_sequence {
  hidden: no
  fields: [ALL_FIELDS*, -customers.has_loan,-customers.number_of_clients_with_loans, -customers.percent_clients_with_loans]
  join: repeat_loan {
    view_label: "Repeat Loan"
    from: loan_sequence
    relationship: one_to_many
    type: left_outer
    sql_on: ${loan_sequence.disp_id} = ${repeat_loan.disp_id}
      and ${loan_sequence.customer_loan_sequence} < ${repeat_loan.customer_loan_sequence};;
  }
  join: second_repeat_loan {
    view_label: "Second Repeat Loan"
    from: loan_sequence
    relationship: one_to_many
    type: left_outer
    sql_on: ${second_repeat_loan.disp_id} = ${repeat_loan.disp_id}
      and ${repeat_loan.customer_loan_sequence} < ${second_repeat_loan.customer_loan_sequence};;
  }
  join: customers {
    relationship: one_to_one
    sql_on: ${loan_sequence.disp_id} = ${customers.disp_id} ;;
  }
  join: customer_attributes {
    relationship: one_to_one
    sql_on: ${customers.client_id} = ${customer_attributes.client_id} ;;
  }
}


explore: events{
  label:  "Lending - Digital Ads"
  join: sessions {
    view_label: "Sessions"
    relationship: many_to_one
    sql_on: ${events.session_id} = ${sessions.session_id} ;;
  }
  join: products {
    view_label: "Products"
    relationship: many_to_one
    sql_on: ${products.id}=cast(${events.viewed_product_id} as int64) ;;
  }
  join: users {
    view_label: "Users"
    relationship: many_to_one
    sql_on: ${sessions.session_user_id} = ${users.id} ;;
    fields: [user_facts*]
  }
  join: user_session_fact {
    view_label: "Users"
    relationship: one_to_one
    sql_on: ${users.id} = ${user_session_fact.session_user_id} ;;
  }

  join: session_purchase_facts {
    view_label: "Session Purchase Facts"
    relationship: many_to_one
    sql_on: ${sessions.session_user_id} = ${session_purchase_facts.session_user_id}
          and ${sessions.session_start_raw} >= ${session_purchase_facts.last_session_end_raw}
          and ${sessions.session_end_raw} <= ${session_purchase_facts.session_end_raw};;
  }

  join: adevents {
    view_label: "Adevents"
    relationship: one_to_many
    sql_on: ${events.ad_event_id} = ${adevents.adevent_id}
      and ${events.referrer_code} = ${adevents.keyword_id}
      and ${events.is_entry_event}
      ;;
  }
  join: keywords {
    view_label: "Keywords"
    relationship: many_to_one
    sql_on:${keywords.keyword_id} = ${adevents.keyword_id} ;;
  }
  join: adgroups{
    view_label: "Adgroups"
    relationship: many_to_one
    sql_on: ${keywords.ad_id} = ${adgroups.ad_id} ;;
  }
  join: campaigns {
    view_label: "Campaigns"
    relationship: many_to_one
    sql_on: ${campaigns.campaign_id} = ${adgroups.campaign_id} ;;
    type: full_outer
  }
}


explore: sessions{
  fields: [ALL_FIELDS*, -sessions.funnel_view*]
  label: "Lending - Marketing Attribution"
  join: adevents {
    relationship: many_to_one
    sql_on: ${adevents.adevent_id} = ${sessions.ad_event_id} ;;
  }
  join: users {
    view_label: "Users"
    relationship: many_to_one
    sql_on: ${sessions.session_user_id} = ${users.id} ;;
    fields: [user_facts*]
  }
  join: user_session_fact {
    view_label: "Users"
    relationship: one_to_one
    sql_on: ${users.id} = ${user_session_fact.session_user_id} ;;
  }

  join: session_attribution {
    view_label: "Session Attribution"
    relationship: many_to_one
    sql_on: ${sessions.session_user_id} = ${session_attribution.session_user_id}
          and ${sessions.session_start_raw} >= ${session_attribution.last_session_end_raw}
          and ${sessions.session_end_raw} <= ${session_attribution.session_end_raw};;
    fields: [attribution_detail*]
  }
  join: keywords {
    view_label: "Keywords"
    relationship: many_to_one
    sql_on:${keywords.keyword_id} = ${adevents.keyword_id} ;;
  }
  join: adgroups{
    view_label: "Adgroups"
    relationship: many_to_one
    sql_on: ${keywords.ad_id} = ${adgroups.ad_id} ;;
  }
  join: campaigns {
    view_label: "Campaigns"
    relationship: many_to_one
    sql_on: ${campaigns.campaign_id} = ${adgroups.campaign_id} ;;
  }
}
