import 'dart:developer' as developer;

/// Debug logging — shows as `[Login]` (or custom [name]) in the console.
// ignore: non_constant_identifier_names
void Log(String message, {String name = 'Login'}) {
  developer.log(message, name: name);
}

String maskToken(String? token) {
  if (token == null || token.isEmpty) return '(empty)';
   return '$token…';
  // return '${token.substring(0, visible)}…(${token.length} chars)';
}



// [Login] user: {id: navigatorengineer_aspect_co_uk, email: navigatorengineer@aspect.co.uk, name: navigatorengineer, role: engineer, azureOid: 7b516fef-43c6-4b97-a59b-06143bb295a4, engineerId: 0Hn4G000000ChrUSAS, tradeGroups: [], firstName: navigatorengineer, lastName: , tripsToday: 14, rating: 4.9, acceptRatePercent: 96, todayEarnings: 131.0}
// [Login] sessionToken: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJhc3BlY3QtZW5naW5lZXItbW9iaWxlIiwic3ViIjoibmF2aWdhdG9yZW5naW5lZXJAYXNwZWN0LmNvLnVrIiwibmFtZSI6Im5hdmlnYXRvcmVuZ2luZWVyIiwicm9sZSI6ImVuZ2luZWVyIiwiZW5naW5lZXJfaWQiOiIwSG40RzAwMDAwMENoclVTQVMiLCJtYW5hZ2VkX2VuZ2luZWVyX2lkcyI6W10sInRyYWRlX2dyb3VwcyI6W10sInJhd190cmFkZV9ncm91cHMiOltdLCJhenVyZV9vaWQiOiI3YjUxNmZlZi00M2M2LTRiOTctYTU5Yi0wNjE0M2JiMjk1YTQiLCJpYXQiOjE3ODA3MzE3NzEsImV4cCI6MTc4MTMzNjU3MX0.G0_n48bT9vKcYKbKS7XBm_X3Iak8C6W-SBs-4XLftZs…