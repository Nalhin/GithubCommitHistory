require('dotenv').config();
const client = require('./apolloClient');
const dataParser = require('./dataParser');
const express = require('express');
const compression = require('compression');
const app = express();
app.use(compression());

const port = process.env.PORT;

app.get('/user/:name', async (req, res) => {
    const {name} = req.params;
    const query = require("./getCommitHistoryQuery");
    try {
        const response = await client.query({
            query,
            variables: {githubUserLogin: name}
        });
        const data = dataParser(response.data, name);
        res.send(data);
    } catch (e) {
        console.log(e)
        return res.send([]);
    }
});

app.listen(port, () => console.log(`Server up and running on ${port}`));



