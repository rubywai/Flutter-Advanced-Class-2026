import "package:crypto_price_app/features/news/ui/screen/news_page.dart";
import "package:crypto_price_app/features/prices/ui/screen/price_list_screen.dart";
import "package:crypto_price_app/features/setttings/ui/setting_screen.dart";
import "package:go_router/go_router.dart";

import "../../features/home/screens/home_page.dart";
import "../../features/overview/ui/screens/overview_screen.dart";
GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(path: '/',
              builder: (context, state) => const OverviewScreen(),),
            ]
          ),
          StatefulShellBranch(
              routes: [
                GoRoute(path: '/prices',
                builder: (context, state) => const PriceListScreen(),)
              ]
          ),
          StatefulShellBranch(
              routes: [
                GoRoute(path: '/news',
                builder: (context, state) => const NewsPage(),)
              ]
          ),
          StatefulShellBranch(
              routes: [
                GoRoute(path: '/setting',
                builder: (context, state) => const SettingScreen(),)
              ]
          ),
        ],
        builder: (context, state, navigationShell){
          return HomePage(shell: navigationShell);
        }
    )
  ],
);