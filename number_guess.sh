#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

INITIALIZATION() {
  echo -e "\n~~~~~ Number Guessing Game ~~~~~\n" 
  echo "Enter your username:"
  # READING USERNAME FROM USER
  read USERNAME
  # MAKING FIRST QUERY IN "users" TO OBTAIN USER_ID.
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  
  # USING FLAG -N FOR USER_ID IF ITS NOT NEW
  if [[ -n $USER_ID ]] 
  then
    # CHECKING PREVIOUS ATTEMPTS 
    PREVIOUS_ATTEMPTS=$($PSQL "SELECT count(user_id) FROM games WHERE user_id = '$USER_ID'")
    # CHECKING THE BEST ATTEMPT
    BEST_ATTEMPT=$($PSQL "SELECT min(attempts) FROM games WHERE user_id = '$USER_ID'")
    # ECHO INFORMATION ABOUT USER "N"
    echo -e "Welcome back, $USERNAME! You have played $PREVIOUS_ATTEMPTS games, and your best game took $BEST_ATTEMPT guesses."
  else
    # IF NEW THEN 
    echo -e "Welcome, $USERNAME! It looks like this is your first time here."
    # INSERT NEW VALUES INTO DB
    INSERT_INTO_USERS=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    # GETTING USER_ID FROM THE NEW USER
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
  fi
  # CALL GAME FUNCTION
  GUESS_NUMBER_GAME
}


# CREATING GAME FUNCTION
GUESS_NUMBER_GAME() {
  # VARIABLES FOR THE GAME
  # RANDOM NUMBER
  NUMBER_GUESS=$((1 + $RANDOM % 1000))
  # COUNTER
  ATTEMPTS=0
  # COUNTER FOR GAMES
  TIMES_GUESSED=0
  echo -e "Guess the secret number between 1 and 1000:"
  
  while [[ $TIMES_GUESSED = 0 ]]; 
  do
    # READING NUMBER INPUT
    read GUESS
    # CHECKING IF IT IS AN INTEGER
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; 
    then
      echo -e "That is not an integer, guess again:"
    # IF IT IS AN INTEGER CHECK IF IT IS EQUAL TO RANDOM
    elif [[ $NUMBER_GUESS = $GUESS ]]; 
    then
      # IF IT IS GUESSED
      ATTEMPTS=$(($ATTEMPTS + 1))
      echo -e "You guessed it in $ATTEMPTS tries. The secret number was $NUMBER_GUESS. Nice job!"
      INSERTED_INTO_GAMES=$($PSQL "INSERT INTO games(user_id, attempts) VALUES($USER_ID, $ATTEMPTS)")
      TIMES_GUESSED=1
    # IF IT IS NOT GUESSED AND IS TOO LOW
    elif [[ $NUMBER_GUESS -gt $GUESS ]] 
    then
      # ADD TO THE COUNTER
      ATTEMPTS=$(($ATTEMPTS + 1))
      echo -e "It's higher than that, guess again:"
    else
    # IF IT IS NOT GUESSED AND IS TOO BIG
      ATTEMPTS=$(($ATTEMPTS + 1))
      echo -e "It's lower than that, guess again:"
    fi
  done
}

INITIALIZATION
