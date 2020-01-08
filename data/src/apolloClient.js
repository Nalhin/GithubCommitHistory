const fetch = require('node-fetch');
const {ApolloClient} = require("apollo-client");
const {createHttpLink} = require("apollo-link-http");
const {setContext} = require("apollo-link-context");
const {InMemoryCache} = require('apollo-cache-inmemory');

const httpLink = createHttpLink({
    uri: 'https://api.github.com/graphql',
    fetch: fetch
});

const authLink = setContext((_, {headers}) => {
    return {
        headers: {
            ...headers,
            authorization: `Bearer ${process.env.GITHUB_TOKEN}`,
        }
    }
});


const client = new ApolloClient({
    link: authLink.concat(httpLink),
    cache: new InMemoryCache()
});

module.exports = client;