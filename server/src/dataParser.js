const dataParser = (data, login) => {
    const commits = [];

    data.user.repositories.nodes.forEach((repo) => {
        repo.refs.edges.forEach((ref) =>
            ref.node.target.history.edges.forEach((commit) => {
                const languages = repo.languages.nodes.map((language) => ({
                        name: language.name,
                        color: language.color
                    })
                );
                const {__typename, author, committer, ...rest} = commit.node;

                if ((author.user && author.user.login === login) || (committer.user && committer.user.login === login)) {
                    const languageData = languages.length > 0 ? {
                        language: languages[0].name || 'None',
                        languageColor: languages[0].color || '#ffffff'
                    } : {language: "None", languageColor: "#ffffff"};

                    commits.push({
                        ...rest,
                        ...languageData,
                        repositoryName: repo.name,
                        repositoryUrl: repo.url,
                    });
                }
            }),
        );
    });
    commits.sort(
        (a, b) => a.committedDate.localeCompare(b.committedDate),
    );
    return commits
};

module.exports = dataParser;