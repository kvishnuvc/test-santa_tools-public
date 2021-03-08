#!/bin/bash
PROJECT_NAME=test-santa_tools

rm -rf $PROJECT_NAME

git clone "https://github.com/kvishnuvc/${PROJECT_NAME}"

PROJECT_PUBLIC_NAME="https://github.com/kvishnuvc/${PROJECT_NAME}-public"

BRANCH_NAME_DEV_PUBLIC="develop-public"
BRANCH_NAME_DEVELOP="develop"
CURRENT_FOLDER_PATH=$(pwd)

echo "Checking if branch ${BRANCH_NAME_DEV_PUBLIC} exists for project: ${PROJECT_NAME}"

#entering to project folder
cd $CURRENT_FOLDER_PATH/$PROJECT_NAME

#Adding remote repository with name of "public"
git remote add public $PROJECT_PUBLIC_NAME

NOW=$(date +"%Y-%m-%d%H%M")
branch='remotes/origin/develop-public2'
existed_in_local=$(git branch -a |grep ${branch})

if [[ -z `git branch -a |grep $BRANCH_NAME_DEV_PUBLIC` ]]
then
   echo 0
else
   echo 1
fi
# checks if branch $BRANCH_NAME_DEV_PUBLIC exits 
# -z command return TRUE if result of grep operation is empty 
if [[ -z `git branch -a |grep $BRANCH_NAME_DEV_PUBLIC` ]]
then
  
   echo "Branch name $BRANCH_NAME_DEV_PUBLIC does not exists."
   echo "Creating --orphan new branch: ${BRANCH_NAME_DEV_PUBLIC}"
   git checkout --orphan $BRANCH_NAME_DEV_PUBLIC
   
   git add -u
   git add .

   git commit -m "upstream: b=develop,t=${NOW}"

   git push origin ${BRANCH_NAME_DEV_PUBLIC}
   COMMIT_ID=$(git rev-parse --verify HEAD)

   git push public $COMMIT_ID":refs/heads/master"


else

 echo "Branch name $BRANCH_NAME_DEV_PUBLIC already exists."
   current_time=$(date "+%Y.%m.%d-%H.%M.%S")
   tmpBranchName=$BRANCH_NAME_DEV_PUBLIC.$current_time

   # creating new temp branch to squash all the changes
   git branch  $tmpBranchName
   git checkout  $tmpBranchName
   # git checkout --orphan $tmpBranchName
   
   git add -u
   git add .

   git commit -m "upstream: b=develop,t=${NOW}"
   COMMIT_ID=$(git rev-parse --verify HEAD)

   # Switching to deveop-public branch to cherry pick all the changes
   # and commiting changes
   git checkout $BRANCH_NAME_DEV_PUBLIC
   git cherry-pick -n $COMMIT_ID --strategy-option theirs
   git commit -m "upstream: b=develop,t=${NOW}"
   git push origin ${BRANCH_NAME_DEV_PUBLIC}

   COMMIT_ID=$(git rev-parse --verify HEAD)

   #pushing to public repo
   git fetch public
   git checkout public/master
   git cherry-pick -n $COMMIT_ID --strategy-option theirs
   git commit -m "upstream: b=master,t=${NOW}"
   
   COMMIT_ID=$(git rev-parse --verify HEAD)
   git push public $COMMIT_ID":refs/heads/master"

   # deleting temp branch
   git checkout $BRANCH_NAME_DEVELOP
   git branch -d $tmpBranchName

fi
cd ../
