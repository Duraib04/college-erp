import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/data_service.dart';
import '../../../../core/theme/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isLoading = false;
  int _selectedRole = 0;

  final List<String> _roles = ['Student', 'Faculty'];
  final List<IconData> _roleIcons = [Icons.school, Icons.person];
  final List<String> _placeholders = ['Eg. STU001', 'Eg. FAC001'];
  final List<_QuickDemoAccount> _quickDemoAccounts = const [
    _QuickDemoAccount(label: 'Student', userId: 'STU001', password: 'ksrce@stu001', icon: Icons.school_outlined),
    _QuickDemoAccount(label: 'Faculty', userId: 'FAC001', password: 'ksrce@fac001', icon: Icons.badge_outlined),
    _QuickDemoAccount(label: 'HOD', userId: 'FAC003', password: 'ksrce@fac003', icon: Icons.workspace_premium_outlined),
    _QuickDemoAccount(label: 'Admin', userId: 'ADM001', password: 'ksrce@adm001', icon: Icons.shield_outlined),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      setState(() {
        _selectedRole = _tabController.index;
        _userIdController.clear();
        _passwordController.clear();
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    await _loginWith(_userIdController.text.trim(), _passwordController.text);
  }

  Future<void> _loginWith(String userId, String password) async {
    setState(() => _isLoading = true);

    final ds = Provider.of<DataService>(context, listen: false);

    await Future.delayed(const Duration(milliseconds: 400));

    if (ds.login(userId, password)) {
      if (!mounted) return;
      context.go(ds.getHomeRouteForCurrentUser());
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Invalid User ID or password. Please try again.'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > 1050;

    return Scaffold(
      body: Stack(
        children: [
          const _LoginBackground(),
          const Positioned(
            left: -160,
            top: 80,
            child: _SoftGlow(size: 420, color: Color(0xFF4C6FFF)),
          ),
          const Positioned(
            right: -180,
            top: 180,
            child: _SoftGlow(size: 460, color: Color(0xFF8F7CFF)),
          ),
          const Positioned(
            left: 40,
            bottom: -120,
            child: _SoftGlow(size: 360, color: Color(0xFFFFD699)),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.center,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1180),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(flex: 3, child: _BrandPanel()),
                            const SizedBox(width: 22),
                            Expanded(
                              flex: 2,
                              child: _LoginFormCard(
                                formKey: _formKey,
                                tabController: _tabController,
                                roles: _roles,
                                roleIcons: _roleIcons,
                                placeholders: _placeholders,
                                userIdController: _userIdController,
                                passwordController: _passwordController,
                                isLoading: _isLoading,
                                obscurePassword: _obscurePassword,
                                rememberMe: _rememberMe,
                                selectedRole: _selectedRole,
                                onToggleRemember: (v) => setState(() => _rememberMe = v ?? false),
                                onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                                onLogin: _login,
                                quickDemoAccounts: _quickDemoAccounts,
                                onQuickDemoLogin: _loginWith,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            const _BrandPanel(),
                            const SizedBox(height: 22),
                            _LoginFormCard(
                              formKey: _formKey,
                              tabController: _tabController,
                              roles: _roles,
                              roleIcons: _roleIcons,
                              placeholders: _placeholders,
                              userIdController: _userIdController,
                              passwordController: _passwordController,
                              isLoading: _isLoading,
                              obscurePassword: _obscurePassword,
                              rememberMe: _rememberMe,
                              selectedRole: _selectedRole,
                              onToggleRemember: (v) => setState(() => _rememberMe = v ?? false),
                              onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                              onLogin: _login,
                              quickDemoAccounts: _quickDemoAccounts,
                              onQuickDemoLogin: _loginWith,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginBackground extends StatelessWidget {
  const _LoginBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF9FAFF), Color(0xFFEAF0FF), Color(0xFFF5F7FF)],
        ),
      ),
      child: CustomPaint(
        painter: _GridPainter(),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  final double size;
  final Color color;

  const _SoftGlow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color.withValues(alpha: 0.24), color.withValues(alpha: 0.02)],
          ),
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF5A67FF).withValues(alpha: 0.14),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/ksrce-logo.png',
                width: 82,
                height: 82,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KSRCE ERP',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Color(0xFF0F2147), height: 1.0),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'COLLEGE OF ENGINEERING',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 1.4, color: Color(0xFF3D4F7A)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_outlined, size: 18, color: Color(0xFF5D4DEF)),
                    SizedBox(width: 8),
                    const Text('Secure Login', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF5D4DEF))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 42),
          const Text(
            'A Smarter ERP for\nModern Campuses',
            style: TextStyle(fontSize: 44, fontWeight: FontWeight.w800, color: Color(0xFF142955), height: 1.02),
          ),
          const SizedBox(height: 18),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 480),
            child: const Text(
              'Streamline academics, simplify operations, and enhance campus experience with a unified platform built for excellence.',
              style: TextStyle(fontSize: 18, height: 1.45, color: Color(0xFF42597E)),
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: const [
              _FeatureBadge(icon: Icons.verified_user_outlined, title: 'Secure Access', subtitle: 'Role-based security'),
              _FeatureBadge(icon: Icons.school_outlined, title: 'Academic Hub', subtitle: 'All academic tools'),
              _FeatureBadge(icon: Icons.bar_chart_outlined, title: 'Insights & Reports', subtitle: 'Real-time analytics'),
              _FeatureBadge(icon: Icons.calendar_month_outlined, title: 'Attendance', subtitle: 'Smart tracking'),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 1.72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/KSRCE-CAMPUS-AERIAL.jpeg', fit: BoxFit.cover),
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x00000000), Color(0x0D102347), Color(0xAA0F2147)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFF0E2B63),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: const Color(0xFF0E2B63).withValues(alpha: 0.22), blurRadius: 28, offset: const Offset(0, 16)),
              ],
            ),
            child: const Row(
              children: [
                Expanded(child: _StatBadge(value: '4,200+', label: 'Students', icon: Icons.groups_outlined)),
                _StatDivider(),
                Expanded(child: _StatBadge(value: '240+', label: 'Faculty', icon: Icons.person_outline)),
                _StatDivider(),
                Expanded(child: _StatBadge(value: '16', label: 'Departments', icon: Icons.apartment_outlined)),
                _StatDivider(),
                Expanded(child: _StatBadge(value: '92%', label: 'Placements', icon: Icons.emoji_events_outlined)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _FeatureBadge({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDE5FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: const Color(0xFF5D4DEF).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 16, color: const Color(0xFF5D4DEF)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF0F2147))),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 10.5, color: Color(0xFF607394), height: 1.15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _StatBadge({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: const Color(0xFFF7B84B), size: 22),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800, height: 1.0)),
          const SizedBox(height: 3),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.82), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  const _StatDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 44, color: Colors.white.withValues(alpha: 0.18));
  }
}

class _LoginFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TabController tabController;
  final List<String> roles;
  final List<IconData> roleIcons;
  final List<String> placeholders;
  final TextEditingController userIdController;
  final TextEditingController passwordController;
  final bool isLoading;
  final bool obscurePassword;
  final bool rememberMe;
  final int selectedRole;
  final ValueChanged<bool?> onToggleRemember;
  final VoidCallback onToggleObscure;
  final VoidCallback onLogin;
  final List<_QuickDemoAccount> quickDemoAccounts;
  final Future<void> Function(String userId, String password) onQuickDemoLogin;
  const _LoginFormCard({
    required this.formKey,
    required this.tabController,
    required this.roles,
    required this.roleIcons,
    required this.placeholders,
    required this.userIdController,
    required this.passwordController,
    required this.isLoading,
    required this.obscurePassword,
    required this.rememberMe,
    required this.selectedRole,
    required this.onToggleRemember,
    required this.onToggleObscure,
    required this.onLogin,
    required this.quickDemoAccounts,
    required this.onQuickDemoLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.75)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F62FF).withValues(alpha: 0.16),
            blurRadius: 40,
            offset: const Offset(0, 24),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Image.asset('assets/images/ksrce-logo.png', width: 92, height: 92, fit: BoxFit.contain),
                  const SizedBox(height: 10),
                  const Text('Welcome Back!', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w800, color: Color(0xFF0F2147), height: 1.0)),
                  const SizedBox(height: 8),
                  Text('Sign in to access your personalized dashboard', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7C98))),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8FF)),
              ),
              child: TabBar(
                controller: tabController,
                indicator: BoxDecoration(
                  color: const Color(0xFF5D4DEF),
                  borderRadius: BorderRadius.circular(10),
                ),
                labelColor: Colors.white,
                unselectedLabelColor: const Color(0xFF54627E),
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                tabs: List.generate(2, (i) => Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(roleIcons[i], size: 18),
                      const SizedBox(width: 6),
                      Text(roles[i]),
                    ],
                  ),
                )),
              ),
            ),
            const SizedBox(height: 22),
            Text('User ID', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: userIdController,
              decoration: InputDecoration(
                hintText: placeholders[tabController.index],
                prefixIcon: const Icon(Icons.person_outline),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Please enter your User ID' : null,
            ),
            const SizedBox(height: 18),
            Text('Password', style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 8),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                if (!isLoading) onLogin();
              },
              decoration: InputDecoration(
                hintText: 'Enter your password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: onToggleObscure,
                    ),
                    IconButton(
                      tooltip: 'Login',
                      icon: const Icon(Icons.arrow_circle_right_outlined, color: AppColors.primary),
                      onPressed: isLoading ? null : onLogin,
                    ),
                  ],
                ),
              ),
              validator: (v) => (v == null || v.isEmpty) ? 'Please enter your password' : null,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading ? null : onLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D4DEF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Sign In'),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: onToggleRemember,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                ),
                Text('Remember me', style: Theme.of(context).textTheme.bodySmall),
                const Spacer(),
                TextButton(
                  onPressed: () => _showForgotPasswordDialog(context),
                  child: Text('Forgot Password?', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primary)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(height: 28),
            Center(
              child: Text('OR', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF97A3B7), letterSpacing: 1.2)),
            ),
            const SizedBox(height: 16),
            _QuickDemoButtonGrid(
              accounts: quickDemoAccounts,
              onLogin: onQuickDemoLogin,
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF6F8FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE3E8FF)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 16, color: const Color(0xFF5D4DEF).withValues(alpha: 0.9)),
                  const SizedBox(width: 8),
                  Text('Your data is secure and encrypted', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: const Color(0xFF6E7B93))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    final resetController = TextEditingController();
    final reasonController = TextEditingController();
    String? message;
    bool isSuccess = false;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  Icon(Icons.lock_reset, color: AppColors.primary),
                  const SizedBox(width: 10),
                  const Text('Reset Password'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter your User ID to raise a password reset request.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Approval flow: Student -> Mentor (if assigned) -> HOD, Faculty -> HOD, HOD -> Admin.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: AppColors.textLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: resetController,
                    decoration: InputDecoration(
                      labelText: 'User ID',
                      hintText: 'Eg. STU001 or PLA001',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonController,
                    minLines: 2,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Reason (optional)',
                      hintText: 'Example: Forgot my password and cannot log in',
                      prefixIcon: const Icon(Icons.notes_outlined),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSuccess ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: isSuccess ? Colors.green : Colors.red, width: 0.5),
                      ),
                      child: Row(
                        children: [
                          Icon(isSuccess ? Icons.check_circle : Icons.error, color: isSuccess ? Colors.green : Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Expanded(child: Text(message!, style: TextStyle(fontSize: 13, color: isSuccess ? Colors.green.shade800 : Colors.red.shade800))),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final uid = resetController.text.trim();
                    if (uid.isEmpty) {
                      setDialogState(() {
                        message = 'Please enter your User ID.';
                        isSuccess = false;
                      });
                      return;
                    }
                    final ds = Provider.of<DataService>(ctx, listen: false);
                    final error = ds.submitPasswordResetRequest(
                      uid,
                      reason: reasonController.text.trim(),
                    );
                    setDialogState(() {
                      if (error == null) {
                        message = 'Request submitted. You will be able to log in with default password after all approvals.';
                        isSuccess = true;
                      } else {
                        message = error;
                        isSuccess = false;
                      }
                    });
                  },
                  child: const Text('Submit Request'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _QuickDemoAccount {
  final String label;
  final String userId;
  final String password;
  final IconData icon;

  const _QuickDemoAccount({required this.label, required this.userId, required this.password, required this.icon});
}

class _QuickDemoButtonGrid extends StatelessWidget {
  final List<_QuickDemoAccount> accounts;
  final Future<void> Function(String userId, String password) onLogin;

  const _QuickDemoButtonGrid({required this.accounts, required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 340;
        final children = accounts.map((account) {
          return SizedBox(
            width: isCompact ? double.infinity : (constraints.maxWidth - 12) / 2,
            child: OutlinedButton.icon(
              onPressed: () => onLogin(account.userId, account.password),
              icon: Icon(account.icon, size: 18, color: const Color(0xFF5D4DEF)),
              label: Text('Quick Demo ${account.label}', style: const TextStyle(fontWeight: FontWeight.w700)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF263658),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFD8DFFF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size(0, 48),
              ),
            ),
          );
        }).toList();

        if (isCompact) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const SizedBox(height: 10),
              ],
            ],
          );
        }

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children,
        );
      },
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2C5282).withValues(alpha: 0.06)
      ..strokeWidth = 1;

    const gap = 42.0;
    for (double x = 0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
