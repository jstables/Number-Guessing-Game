#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

echo "Enter your username:"
read USERNAME

GAME() {

  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo Guess the secret number between 1 and 1000:
  fi

  read GUESS


  if [[ ! "$GUESS" =~ ^[0-9]+$ ]]
  then
  GAME "That is not an integer, guess again:"
  fi

  GUESSES=$((GUESSES + 1))
  if [[ $GUESS == $RANDOM_NUMBER ]]
  then
  echo You guessed it in $GUESSES tries. The secret number was $RANDOM_NUMBER. Nice job!

  UPDATE_GAMES=$($PSQL "UPDATE users SET games_played = (games_played + 1) WHERE user_id=$USER_ID")

  if [[ $GUESSES < $BEST || -z $BEST ]]
  then
  UPDATE_BEST=$($PSQL "UPDATE users SET best_game = $GUESSES WHERE user_id=$USER_ID")
  fi
  else
  if [[ $GUESS -gt $RANDOM_NUMBER ]]
  then
  GAME "It's lower than that, guess again:"
  else
  GAME "It's higher than that, guess again:"
  fi
  fi
}


USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
NAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
GAMES=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
BEST=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

echo $USER_ID $NAME $GAMES $BEST

if [[ -z $USER_ID ]]

then

echo "Welcome, $USERNAME! It looks like this is your first time here."

NEW_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES('$USERNAME', 0)")

else
echo Welcome back, $NAME! You have played $GAMES games, and your best game took $BEST guesses.

fi

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
NAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
GAMES=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
BEST=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

#generate random number
RANDOM_NUMBER=$($PSQL "SELECT floor(random() * 1000 + 1)::int AS random_number")
echo $RANDOM_NUMBER

GUESSES=0

#call game function

GAME

