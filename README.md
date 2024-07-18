# GitHub Repository Viewer

This Flutter application connects to the GitHub API to retrieve and display information about public repositories and their latest commits.

## Features

1. Fetches and displays a list of public repositories for the freeCodeCamp GitHub account.
2. Shows detailed information for each repository in a scrollable list view or grid view, depending on screen size.
3. Asynchronously loads and displays the last commit information for each repository.
4. Implements a responsive design that adapts to different screen sizes.
5. Provides a dark theme with custom color scheme.

## Watch the video by clicking on the thumbnail below:
[![API Endpoints](https://img.youtube.com/vi/5Zwb5aYj7nI/maxresdefault.jpg)](https://www.youtube.com/embed/5Zwb5aYj7nI?si=BUTL81qa17F2n-ur)

## Key Components

### Repository Class
Represents a GitHub repository with the following properties:
- name
- description
- stargazers count
- forks count
- last commit (optional)
- URL

### Commit Class
Represents a GitHub commit with the following properties:
- message
- SHA
- author name
- author email
- date
- URL

## Dependencies

- flutter
- http: For making API requests
- logging: For logging purposes
- flutter_staggered_grid_view: For creating a responsive grid layout
- url_launcher: For opening URLs
- google_fonts: For custom fonts
- flutter_dotenv: For managing environment variables

## Setup

1. Clone the repository
2. Create a `.env` file in the root directory and assets and add your GitHub token: GITHUB_TOKEN=your_github_token_here
3. Run `flutter pub get` to install dependencies
4. Run the app using `flutter run`

## Usage

The app displays a list of freeCodeCamp's public repositories. Each repository card shows:
- Repository name
- Description
- Star count
- Fork count
- Last commit information (if available)
- Commit message
- Author
- Date

Users can tap on a repository card to open its GitHub page in a web browser.

## Error Handling

The app includes error handling for API requests and URL launching. Error messages are displayed to the user when appropriate.

## Responsive Design

The app uses a single-column list view on smaller screens and a grid view on larger screens for optimal display of repository information.

## Contact

### shivkumarraghuwanshi56@gmail.com
### raghuwanshishivkumar56@gmail.com
