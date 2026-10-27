#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"

echo -e "\nHello! Welcome to my salon. How may I help you?\n"

MAIN_MENU() {
  # Get service, repeat if wrong option is input
  echo "$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")" | while IFS="|" read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED

  if [[ $SERVICE_ID_SELECTED != 1 && $SERVICE_ID_SELECTED != 2 && $SERVICE_ID_SELECTED != 3 ]]
  then
    MAIN_MENU
  fi

  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  # Get phone number
  echo -e "\n What is the phone number?"
  read CUSTOMER_PHONE

  # Check for phone number
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]
  then
    echo -e "\nName is not in our database. What is your name?"
    read CUSTOMER_NAME
    INSERT_NAME=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

  echo -e "\n$CUSTOMER_NAME, what time would you like your appointment to be?"
  read SERVICE_TIME

  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")

  if [[ $INSERT_APPOINTMENT="INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU