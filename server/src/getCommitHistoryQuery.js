const gql = require('graphql-tag');

const getCommitHistory = gql`
    query getLatestActivity($githubUserLogin: String!) {
        user(login: $githubUserLogin) {
            repositories(
                first: 100
                orderBy: { field: PUSHED_AT, direction: DESC }
                privacy: PUBLIC
            ) {
                nodes {
                    name
                    url
                    languages(first: 2, orderBy: { field: SIZE, direction: DESC }) {
                        nodes {
                            name
                            color
                        }
                    }
                    refs(
                        refPrefix: "refs/heads/"
                        orderBy: { direction: DESC, field: TAG_COMMIT_DATE }
                        first: 48
                    ) {
                        edges {
                            node {
                                ... on Ref {
                                    target {
                                        ... on Commit {
                                            history(first: 100) {
                                                edges {
                                                    node {
                                                        ... on Commit {
                                                            committedDate
                                                            message
                                                            url
                                                            additions
                                                            deletions
                                                            changedFiles
                                                            id
                                                            committer {
                                                                user {
                                                                    login
                                                                }
                                                            }
                                                            author {
                                                                user {
                                                                    login
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
`;

module.exports = getCommitHistory;