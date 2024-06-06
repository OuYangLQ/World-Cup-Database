#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo "$($PSQL "TRUNCATE TABLE teams,games")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  if [[ $WINNER != "winner" ]]
	then

	  # get id
	  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER' ")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT' ")

    # if not found
    if [[ -z $WINNER_ID ]]
    then

    # insert winner
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")

    fi

    if [[ -z $OPPONENT_ID ]]
    then
      # insert opponent
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
    fi

    if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
    then
        echo Inserted into name, $WINNER
    fi

    if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
    then
        echo Inserted into name, $OPPONENT
    fi

	fi
    
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do

  if [[ $YEAR != "year" ]]
	then

	  # get game_id
	  GAME_ID=$($PSQL "SELECT game_id FROM games
    FULL JOIN teams winner ON games.winner_id=winner.team_id
    FULL JOIN teams opponent ON games.opponent_id=opponent.team_id
    WHERE year='$YEAR' AND round='$ROUND' AND winner.name='$WINNER' AND opponent.name='$OPPONENT'
    AND winner_goals=$WINNER_GOALS AND opponent_goals=$OPPONENT_GOALS")
    
    # if not found
    if [[ -z $GAME_ID ]]
    then

    # get winner_id opponent_id
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$WINNER' ")
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$OPPONENT' ")

    # insert year round winner_id opponent_id winner_goals opponent_goals
      INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year,round,winner_id,opponent_id,winner_goals,opponent_goals)
      VALUES($YEAR,'$ROUND','$WINNER_ID','$OPPONENT_ID','$WINNER_GOALS','$OPPONENT_GOALS')")
      echo $INSERT_GAME_RESULT

      if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into year round winner_id opponent_id winner_goals opponent_goals, $YEAR $ROUND $WINNER_ID $OPPONENT_ID $WINNER_GOALS $OPPONENT_GOALS
      fi

    fi

	fi
    
done