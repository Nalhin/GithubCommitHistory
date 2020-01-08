const dataParser = (data) => {
    const commits = [];

    data.user.repositories.nodes.forEach((repo) => {
        repo.refs.edges.forEach((ref) =>
            ref.node.target.history.edges.forEach((commit) => {
                const languages = repo.languages.nodes.map((language) =>
                    language.name,
                );
                const {__typename, ...rest} = commit.node;
                commits.push({
                    ...rest,
                    languages: languages,
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