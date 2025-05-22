import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:golden_wallet/shared/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';
import 'package:golden_wallet/config/routes.dart';
import 'package:golden_wallet/config/theme.dart';
import 'package:golden_wallet/features/profile/models/user_model.dart';
import 'package:golden_wallet/features/profile/providers/user_provider.dart';
import 'package:golden_wallet/features/profile/widgets/edit_profile_dialog.dart';
import 'package:golden_wallet/features/profile/widgets/profile_header.dart';
import 'package:golden_wallet/features/profile/widgets/profile_section.dart';
import 'package:golden_wallet/shared/widgets/custom_button.dart';

/// Profile screen
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  /// Fetch user data
  Future<void> _fetchUserData() async {
    setState(() {
      _isLoading = true;
    });

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.fetchUser();

    setState(() {
      _isLoading = false;
    });
  }

  /// Show edit profile dialog
  void _showEditProfileDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(
        user: user,
        onSave: (name, email, phoneNumber) {
          userProvider.updateUser(
            name: name,
            email: email,
            phoneNumber: phoneNumber,
          );
        },
      ),
    );
  }

  /// Show edit address dialog
  void _showEditAddressDialog() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    if (user == null) return;

    showDialog(
      context: context,
      builder: (context) => EditAddressDialog(
        address: user.address,
        onSave: (street, city, state, country, postalCode) {
          userProvider.updateAddress(
            street: street,
            city: city,
            state: state,
            country: country,
            postalCode: postalCode,
          );
        },
      ),
    );
  }

  /// Update notification preferences
  Future<void> _updateNotificationPreferences({
    bool? notificationsEnabled,
    bool? emailNotificationsEnabled,
    bool? pushNotificationsEnabled,
    bool? smsNotificationsEnabled,
    bool? biometricAuthEnabled,
  }) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.updatePreferences(
      notificationsEnabled: notificationsEnabled,
      emailNotificationsEnabled: emailNotificationsEnabled,
      pushNotificationsEnabled: pushNotificationsEnabled,
      smsNotificationsEnabled: smsNotificationsEnabled,
      biometricAuthEnabled: biometricAuthEnabled,
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final isRtl = Directionality.of(context) == TextDirection.RTL;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.goldDark),
        ),
      );
    }

    if (user == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: AppTheme.goldColor,
            ),
            const SizedBox(height: 16),
            Text(
              'errorOccurred'.tr(),
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.goldDark,
                  ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'tryAgain'.tr(),
              onPressed: _fetchUserData,
              icon: Icons.refresh,
              type: ButtonType.primary,
              backgroundColor: AppTheme.goldDark,
              textColor: Colors.white,
              width: 200,
            ),
          ],
        ),
      );
    }

    return Scaffold(
  appBar: CustomAppBar(
        title: 'profile'.tr(),
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: AppTheme.goldDark,
            ),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      
      ),

      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchUserData,
          color: AppTheme.goldDark,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile header
                  ProfileHeader(
                    user: user,
                    onEditPressed: _showEditProfileDialog,
                  ),
                  const SizedBox(height: 24),

                  // Profile stats
                  ProfileStats(
                    transactionsCount: 12, // Mock data
                    goldBalance: 2.5, // Mock data
                    cashBalance: 1250.75, // Mock data
                  ),
                  const SizedBox(height: 24),

                  // Personal information section
                  ProfileSection(
                    title: 'personalInformation'.tr(),
                    showEditButton: true,
                    onEditPressed: _showEditProfileDialog,
                    children: [
                      ProfileInfoItem(
                        icon: Icons.email,
                        label: 'email'.tr(),
                        value: user.email,
                      ),
                      ProfileInfoItem(
                        icon: Icons.phone,
                        label: 'phoneNumber'.tr(),
                        value: user.phoneNumber,
                      ),
                      ProfileInfoItem(
                        icon: Icons.calendar_today,
                        label: 'memberSince'.tr(),
                        value:
                            DateFormat('MMMM dd, yyyy').format(user.createdAt),
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Address section
                  if (user.address != null)
                    ProfileSection(
                      title: 'address'.tr(),
                      showEditButton: true,
                      onEditPressed: _showEditAddressDialog,
                      children: [
                        ProfileInfoItem(
                          icon: Icons.location_on,
                          label: 'street'.tr(),
                          value: user.address!.street,
                        ),
                        ProfileInfoItem(
                          icon: Icons.location_city,
                          label: 'city'.tr(),
                          value: user.address!.city,
                        ),
                        ProfileInfoItem(
                          icon: Icons.map,
                          label: 'state'.tr(),
                          value: user.address!.state,
                        ),
                        ProfileInfoItem(
                          icon: Icons.public,
                          label: 'country'.tr(),
                          value: user.address!.country,
                        ),
                        ProfileInfoItem(
                          icon: Icons.markunread_mailbox,
                          label: 'postalCode'.tr(),
                          value: user.address!.postalCode,
                          isLast: true,
                        ),
                      ],
                    ),
                  if (user.address != null) const SizedBox(height: 24),

                  // Security section
                  ProfileSection(
                    title: 'security'.tr(),
                    children: [
                      ProfileActionItem(
                        icon: Icons.lock,
                        title: 'changePassword'.tr(),
                        onTap: () {
                          // Navigate to change password screen
                          Navigator.pushNamed(context, AppRoutes.resetPassword);
                        },
                      ),
                      ProfileToggleItem(
                        icon: Icons.fingerprint,
                        title: 'biometricAuthentication'.tr(),
                        value: user.preferences.biometricAuthEnabled,
                        onChanged: (value) {
                          _updateNotificationPreferences(
                            biometricAuthEnabled: value,
                          );
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Notification preferences section
                  ProfileSection(
                    title: 'notificationPreferences'.tr(),
                    children: [
                      ProfileToggleItem(
                        icon: Icons.notifications,
                        title: 'enableNotifications'.tr(),
                        value: user.preferences.notificationsEnabled,
                        onChanged: (value) {
                          _updateNotificationPreferences(
                            notificationsEnabled: value,
                          );
                        },
                      ),
                      ProfileToggleItem(
                        icon: Icons.email,
                        title: 'emailNotifications'.tr(),
                        value: user.preferences.emailNotificationsEnabled,
                        onChanged: (value) {
                          _updateNotificationPreferences(
                            emailNotificationsEnabled: value,
                          );
                        },
                      ),
                      ProfileToggleItem(
                        icon: Icons.notifications_active,
                        title: 'pushNotifications'.tr(),
                        value: user.preferences.pushNotificationsEnabled,
                        onChanged: (value) {
                          _updateNotificationPreferences(
                            pushNotificationsEnabled: value,
                          );
                        },
                      ),
                      ProfileToggleItem(
                        icon: Icons.sms,
                        title: 'smsNotifications'.tr(),
                        value: user.preferences.smsNotificationsEnabled,
                        onChanged: (value) {
                          _updateNotificationPreferences(
                            smsNotificationsEnabled: value,
                          );
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Account actions section
                  ProfileSection(
                    title: 'accountActions'.tr(),
                    children: [
                      ProfileActionItem(
                        icon: Icons.history,
                        title: 'transactionHistory'.tr(),
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.transactions);
                        },
                      ),
                      ProfileActionItem(
                        icon: Icons.support_agent,
                        title: 'customerSupport'.tr(),
                        onTap: () {
                          // Navigate to customer support screen
                        },
                      ),
                      ProfileActionItem(
                        icon: Icons.logout,
                        title: 'logout'.tr(),
                        iconColor: AppTheme.errorColor,
                        onTap: () {
                          // Show logout confirmation dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('logout'.tr()),
                              content: Text('logoutConfirmation'.tr()),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    'cancel'.tr(),
                                    style: TextStyle(
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Perform logout
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRoutes.login,
                                      (route) => false,
                                    );
                                  },
                                  child: Text(
                                    'logout'.tr(),
                                    style: TextStyle(
                                      color: AppTheme.errorColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
