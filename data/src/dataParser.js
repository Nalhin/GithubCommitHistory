const dataParser = (data) => {
    const commits = [];

    data.user.repositories.nodes.forEach((repo) => {
        repo.refs.edges.forEach((ref) =>
            ref.node.target.history.edges.forEach((commit) => {
                const languages = repo.languages.nodes.map((language) => ({
                        name: language.name,
                        color: language.color
                    })
                );
                const {__typename, ...rest} = commit.node;
                commits.push({
                    ...rest,
                    language: languages[0].name,
                    languageColor: languages[0].color || '#ffffff',
                    repositoryName: repo.name,
                    repositoryUrl: repo.url,
                });
            }),
        );
    });
    commits.sort(
        (a, b) => a.committedDate.localeCompare(b.committedDate),
    );
    return commits
};

module.exports = dataParser;