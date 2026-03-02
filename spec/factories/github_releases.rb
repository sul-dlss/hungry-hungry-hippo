# frozen_string_literal: true

FactoryBot.define do
  factory :github_release do
    github_repository
    release_id { 291_510_692 }
    release_tag { 'test4' }
    release_name { 'Release 4' }
    published_at { 2.days.ago }
    message do
      {
        url: 'https://api.github.com/repos/amyehodge/ghtest2/releases/291510692',
        assets_url: 'https://api.github.com/repos/amyehodge/ghtest2/releases/291510692/assets',
        upload_url: 'https://uploads.github.com/repos/amyehodge/ghtest2/releases/291510692/assets{?name,label}',
        html_url: 'https://github.com/amyehodge/ghtest2/releases/tag/test4',
        id: 291_510_692,
        author: {
          login: 'amyehodge',
          id: 5_558_511,
          node_id: 'MDQ6VXNlcjU1NTg1MTE=',
          avatar_url: 'https://avatars.githubusercontent.com/u/5558511?v=4',
          gravatar_id: '',
          url: 'https://api.github.com/users/amyehodge',
          html_url: 'https://github.com/amyehodge',
          followers_url: 'https://api.github.com/users/amyehodge/followers',
          following_url: 'https://api.github.com/users/amyehodge/following{/other_user}',
          gists_url: 'https://api.github.com/users/amyehodge/gists{/gist_id}',
          starred_url: 'https://api.github.com/users/amyehodge/starred{/owner}{/repo}',
          subscriptions_url: 'https://api.github.com/users/amyehodge/subscriptions',
          organizations_url: 'https://api.github.com/users/amyehodge/orgs',
          repos_url: 'https://api.github.com/users/amyehodge/repos',
          events_url: 'https://api.github.com/users/amyehodge/events{/privacy}',
          received_events_url: 'https://api.github.com/users/amyehodge/received_events',
          type: 'User',
          user_view_type: 'public',
          site_admin: false
        },
        node_id: 'RE_kwDORTabBc4RYBmk',
        tag_name: 'test4',
        target_commitish: 'main',
        name: 'Release 4',
        draft: false,
        immutable: false,
        prerelease: false,
        created_at: '2026-02-18 21:14:09 UTC',
        updated_at: '2026-02-27 20:52:20 UTC',
        published_at: '2026-02-27 20:52:20 UTC',
        assets: [{
          url: 'https://api.github.com/repos/amyehodge/ghtest2/releases/assets/363708809',
          id: 363_708_809,
          node_id: 'RA_kwDORTabBc4VrcGJ',
          name: 'Feb18_2026_collection_report.csv',
          label: nil,
          uploader: {
            login: 'amyehodge',
            id: 5_558_511,
            node_id: 'MDQ6VXNlcjU1NTg1MTE=',
            avatar_url: 'https://avatars.githubusercontent.com/u/5558511?v=4',
            gravatar_id: '',
            url: 'https://api.github.com/users/amyehodge',
            html_url: 'https://github.com/amyehodge',
            followers_url: 'https://api.github.com/users/amyehodge/followers',
            following_url: 'https://api.github.com/users/amyehodge/following{/other_user}',
            gists_url: 'https://api.github.com/users/amyehodge/gists{/gist_id}',
            starred_url: 'https://api.github.com/users/amyehodge/starred{/owner}{/repo}',
            subscriptions_url: 'https://api.github.com/users/amyehodge/subscriptions',
            organizations_url: 'https://api.github.com/users/amyehodge/orgs',
            repos_url: 'https://api.github.com/users/amyehodge/repos',
            events_url: 'https://api.github.com/users/amyehodge/events{/privacy}',
            received_events_url: 'https://api.github.com/users/amyehodge/received_events',
            type: 'User',
            user_view_type: 'public',
            site_admin: false
          },
          content_type: 'text/csv',
          state: 'uploaded',
          size: 93_240,
          digest: 'sha256:4a4ccb52580ffe7cad83f3673782da80f43f4b937239d58e3f6ec3e9d436421c',
          download_count: 0,
          created_at: '2026-02-27 20:52:00 UTC',
          updated_at: '2026-02-27 20:52:00 UTC',
          browser_download_url: 'https://github.com/amyehodge/ghtest2/releases/download/test4/Feb18_2026_collection_report.csv'
        }],
        tarball_url: 'https://api.github.com/repos/amyehodge/ghtest2/tarball/test4',
        zipball_url: 'https://api.github.com/repos/amyehodge/ghtest2/zipball/test4',
        body: "**Full Changelog**: https://github.com/amyehodge/ghtest2/commits/test4\r\n\r\nSome extra notes."
      }
    end
  end
end
