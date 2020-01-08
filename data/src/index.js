const fs = require('fs');
require('dotenv').config();
const client = require('./apolloClient');
const dataParser = require('./dataParser');

(async () => {
    const query = require("./getCommitHistoryQuery");
    const response = await client.query({
        query,
        variables: {githubUserLogin: "Nalhin"}
    });

    const data = dataParser(response.data);
    fs.writeFileSync(`${__dirname}/../../commitData.json`, JSON.stringify(data));
    console.log('Success!')
})();


