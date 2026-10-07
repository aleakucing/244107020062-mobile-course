const routeLogin = "/login";
const routeHome = "/";
const routeAnnouncementPattern = "/pengumuman/:id";
const topicPengumuman = "pengumuman-kampus";

String announcementRoute(String id) => "/pengumuman/$id";

String? authRedirect({required bool loggedIn, required String location}) {
  final goingLogin = location == routeLogin;
  if (!loggedIn && !goingLogin) return routeLogin;
  if (loggedIn && goingLogin) return routeHome;
  return null;
}
