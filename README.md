# GithubCommitHistory

A web application that analizes commit history of Github users. It utilizes custom express server to proxy and parse responses from Github API mainly due to the fact that Github doesn't provide GraphQL API without authorization.


## Technology Stack

* R
* Shiny R
* Node
* Express
* Apollo Client
* GraphQL

## Requirements

Install node package manager [npm](https://www.npmjs.com/).
You should be able to run the following commands.

```bash
node --version
npm --version
```

## Backend 

#### Installation

```bash
git clone https://github.com/Nalhin/GithubCommitHistory
cd server && npm install
```

####  Start

```bash
cd server && npm run start
```