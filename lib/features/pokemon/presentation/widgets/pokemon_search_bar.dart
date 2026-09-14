import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/pokemon_search_provider.dart';

class PokemonSearchBar extends ConsumerStatefulWidget {
  const PokemonSearchBar({super.key});

  @override
  ConsumerState<PokemonSearchBar> createState() => _PokemonSearchBarState();
}

class _PokemonSearchBarState extends ConsumerState<PokemonSearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(pokemonSearchQueryProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        onChanged: (val) {
          ref.read(pokemonSearchQueryProvider.notifier).state = val;
        },
        decoration: InputDecoration(
          hintText: 'Search by name or #ID (e.g. 25, pikachu)...',
          hintStyle: TextStyle(
            fontSize: 13.sp,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: AppColors.primaryRed,
            size: 22.sp,
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, size: 18.sp),
                  onPressed: () {
                    _controller.clear();
                    ref.read(pokemonSearchQueryProvider.notifier).state = '';
                    setState(() {});
                  },
                )
              : null,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}
