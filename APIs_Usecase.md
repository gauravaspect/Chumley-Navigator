1) /api/auth/mobile/exchange (POST)
Used during the Microsoft authentication flow. After the engineer signs in via Microsoft Azure AD, the app receives the Azure ID token and access token. These tokens are POSTed to this endpoint to exchange them for a server-side session token (JWT) and fetch user details. The session token is stored locally to authorize all subsequent API calls.

2) /api/auth/signout (POST)
Used when the engineer logs out of the application. It sends a request to invalidate the active session token on the server. After the call completes (or fails due to connectivity), the app clears all locally stored user credentials and session data and routes the user back to the login screen.

3) /api/engineer/{id} (GET)
Used to fetch detailed profile information, ratings, historical trade statistics, and performance metrics (conversion rate, productivity, procedural compliance, vehicular driving score, customer satisfaction (C-SAT) rating, etc.) for the logged-in engineer. This data is displayed on the main dashboard and profile screens. It supports filtering data using the `date_range` query parameter.

4) /api/engineers/{id}/points/summary (GET)
Used to fetch the performance points summary history for the engineer. It retrieves points data over a specified period of months (passed via query parameter `months`). This information is used to show historical point trends and monitor progress towards points milestones.

5) /api/vcr/allocations (GET)
Used in the Vehicle Check (VCR) flow to fetch the details of the active vehicle allocated to the logged-in engineer, such as registration number and make/model, ensuring they are inspecting the correct vehicle.

6) /api/vcr/examples/{section} (GET)
Used during the Vehicle Condition Report (VCR) inspection to retrieve reference/example photos for a specific check section (e.g., front overview, wheels, engine coolant level). These images are displayed in the inspection UI to guide the engineer on what kind of photo needs to be captured.

7) /api/vcr/submit (POST, multipart/form-data)
Used to submit the completed Vehicle Condition Report (VCR) inspection. It uploads the vehicle ID, overall pass/fail inspection result, descriptions/internal notes, and the set of inspection photos captured by the engineer.

8) /api/leaderboard (GET)
Used to fetch leaderboard rankings of the engineers. The retrieved rankings, overall rating, monthly points, and trade positions are displayed in the Leaderboard screen to facilitate transparency and friendly competition.

9) /api/engineer/absences (GET)
Used to fetch a list of all current, upcoming, and historical absences (e.g., sick leave, holidays, medical appointments) logged by the engineer. The results are displayed in the absences list view.

10) /api/engineer/absences (POST)
Used to submit a new absence request. The engineer provides the absence type, start date/time, end date/time, and description. This request is sent to the backend for recording and approval.