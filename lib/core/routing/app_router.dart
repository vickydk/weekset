/// Paths for the four shells. A role only renders its own prefix.
abstract final class AppRouter {
  static const welcome = '/welcome';
  static const locked = '/locked';
  static const suspended = '/suspended';

  static const clientHome = '/client/home';
  static const clientSchedule = '/client/schedule';
  static const clientHistory = '/client/history';
  static const clientProfile = '/client/profile';

  static const trainerToday = '/trainer/today';
  static const trainerAvailability = '/trainer/availability';
  static const trainerClients = '/trainer/clients';
  static const trainerProfile = '/trainer/profile';

  static const managerToday = '/manager/today';
  static const managerPeople = '/manager/people';
  static const managerSchedule = '/manager/schedule';
  static const managerBranch = '/manager/branch';

  static const centerToday = '/center/today';
  static const centerBranches = '/center/branches';
  static const centerPeople = '/center/people';
  static const centerProfile = '/center/profile';

  static String homeFor(String? role) {
    return switch (role) {
      'trainer' => trainerToday,
      'manager' => managerToday,
      'center_admin' => centerToday,
      _ => clientHome,
    };
  }

  static bool allows(String? role, String path) {
    final prefix = switch (role) {
      'trainer' => '/trainer/',
      'manager' => '/manager/',
      'center_admin' => '/center/',
      _ => '/client/',
    };
    return path.startsWith(prefix);
  }

  static String coerce(String? role, String path) {
    return allows(role, path) ? path : homeFor(role);
  }
}
