#! /bin/bash
# Script for the number guessing game

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate a random number between 1 and 1000
NUM=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

# Get user record from users table in number_guess database
USER_RECORD=$($PSQL "SELECT games_played, best_game FROM users WHERE username = '$USERNAME'")

# Check if the user is new (the record is empty)
if [[ -z $USER_RECORD ]]
then
  # Create a new user
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username = '$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

# Set guess count
GUESS_COUNT=0

GET_GUESS() {
  # If there is a message in args
  if [[ $1 ]]
  then
    # Print message
    echo "$1"
  else
    # Get the first guess
    echo "Guess the secret number between 1 and 1000:"
  fi

  read GUESS

  # Verify that the guess is an integer
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    # Prompt the user to enter an integer
    GET_GUESS "That is not an integer, guess again:"
  fi

  (( GUESS_COUNT++ ))
}

GET_GUESS

while [[ $GUESS != $NUM ]]
do
  if [[ $GUESS -gt $NUM ]]
  then
    GET_GUESS "It's lower than that, guess again:"
  fi

  if [[ $GUESS -lt $NUM ]]
  then
    GET_GUESS "It's higher than that, guess again:"
  fi
done

# Update user record for games played
(( GAMES_PLAYED++ ))
UPDATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE username = '$USERNAME'")

BEST_SCORE=$($PSQL "SELECT best_game FROM users WHERE username = '$USERNAME'")

if [[ -z $BEST_SCORE || ($GUESS_COUNT -lt $BEST_SCORE) ]]
then
  # Update user record for best game
  UPDATE_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $GUESS_COUNT WHERE username = '$USERNAME'")
fi

echo "You guessed it in $GUESS_COUNT tries. The secret number was $NUM. Nice job!"
