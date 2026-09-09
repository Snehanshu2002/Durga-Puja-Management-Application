import 'package:flutter/material.dart';
import 'package:durgapuja_manager/core/theme/app_colors.dart';

class SearchablePickerField<T> extends FormField<T> {
  final String title;
  final String searchHint;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemTitle;
  final String Function(T)? itemSubtitle;
  final Widget Function(T)? itemTrailing;
  final Widget Function(T)? itemLeading;
  final bool Function(T item, String query) searchFilter;
  final ValueChanged<T?> onChanged;
  final String? placeholder;
  final IconData prefixIcon;

  SearchablePickerField({
    super.key,
    required this.title,
    required this.items,
    required this.itemTitle,
    required this.searchFilter,
    required this.onChanged,
    this.searchHint = 'Type to search...',
    this.selectedItem,
    this.itemSubtitle,
    this.itemTrailing,
    this.itemLeading,
    this.placeholder = 'Tap to select...',
    this.prefixIcon = Icons.person_search,
    super.enabled,
    super.validator,
    super.autovalidateMode,
  }) : super(
          initialValue: selectedItem,
          builder: (FormFieldState<T> state) {
            final context = state.context;
            final current = state.value;
            final hasError = state.hasError;
            final isFieldEnabled = state.widget.enabled;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: isFieldEnabled
                      ? () async {
                          final result = await showModalBottomSheet<T>(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (ctx) => _SearchablePickerSheet<T>(
                              title: title,
                              searchHint: searchHint,
                              items: items,
                              selectedItem: current,
                              itemTitle: itemTitle,
                              itemSubtitle: itemSubtitle,
                              itemTrailing: itemTrailing,
                              itemLeading: itemLeading,
                              searchFilter: searchFilter,
                            ),
                          );

                          if (result != null) {
                            state.didChange(result);
                            onChanged(result);
                          }
                        }
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isFieldEnabled ? Colors.white : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: hasError
                            ? AppColors.error
                            : (current != null ? AppColors.primary : Colors.grey.shade400),
                        width: hasError || current != null ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          prefixIcon,
                          color: current != null ? AppColors.primary : Colors.grey.shade600,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: current != null
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      itemTitle(current),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textPrimaryLight,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    if (itemSubtitle != null && itemSubtitle(current).isNotEmpty)
                                      Text(
                                        itemSubtitle(current),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                  ],
                                )
                              : Text(
                                  placeholder ?? 'Tap to select...',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                        ),
                        if (current != null && isFieldEnabled)
                          InkWell(
                            onTap: () {
                              state.didChange(null);
                              onChanged(null);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: Icon(Icons.close, size: 18, color: Colors.grey.shade600),
                            ),
                          )
                        else
                          Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ),
                if (hasError)
                  Padding(
                    padding: const EdgeInsets.only(left: 12, top: 6),
                    child: Text(
                      state.errorText ?? '',
                      style: const TextStyle(
                        color: AppColors.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );
}

class _SearchablePickerSheet<T> extends StatefulWidget {
  final String title;
  final String searchHint;
  final List<T> items;
  final T? selectedItem;
  final String Function(T) itemTitle;
  final String Function(T)? itemSubtitle;
  final Widget Function(T)? itemTrailing;
  final Widget Function(T)? itemLeading;
  final bool Function(T item, String query) searchFilter;

  const _SearchablePickerSheet({
    required this.title,
    required this.searchHint,
    required this.items,
    required this.selectedItem,
    required this.itemTitle,
    required this.itemSubtitle,
    required this.itemTrailing,
    required this.itemLeading,
    required this.searchFilter,
  });

  @override
  State<_SearchablePickerSheet<T>> createState() => _SearchablePickerSheetState<T>();
}

class _SearchablePickerSheetState<T> extends State<_SearchablePickerSheet<T>> {
  late final TextEditingController _searchController;
  List<T> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredItems = List.from(widget.items);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    final cleanQuery = query.trim().toLowerCase();
    setState(() {
      if (cleanQuery.isEmpty) {
        _filteredItems = List.from(widget.items);
      } else {
        _filteredItems = widget.items.where((item) => widget.searchFilter(item, cleanQuery)).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Container(
      height: mediaQuery.size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          _onSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Items Count Badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredItems.length} members found',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                ),
                if (_searchController.text.isNotEmpty)
                  Text(
                    'Searching for "${_searchController.text}"',
                    style: const TextStyle(fontSize: 12, color: AppColors.primary, fontStyle: FontStyle.italic),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // List of filtered items
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search_off, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text(
                            'No members match "${_searchController.text}"',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: _filteredItems.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      final item = _filteredItems[index];
                      final isSelected = widget.selectedItem == item;

                      return ListTile(
                        selected: isSelected,
                        selectedTileColor: AppColors.primarySurface,
                        leading: widget.itemLeading != null
                            ? widget.itemLeading!(item)
                            : CircleAvatar(
                                radius: 18,
                                backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
                                foregroundColor: isSelected ? Colors.white : AppColors.primaryDark,
                                child: Text(
                                  widget.itemTitle(item).isNotEmpty
                                      ? widget.itemTitle(item)[0].toUpperCase()
                                      : 'M',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ),
                        title: Text(
                          widget.itemTitle(item),
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                            color: isSelected ? AppColors.primary : AppColors.textPrimaryLight,
                          ),
                        ),
                        subtitle: widget.itemSubtitle != null && widget.itemSubtitle!(item).isNotEmpty
                            ? Text(widget.itemSubtitle!(item))
                            : null,
                        trailing: widget.itemTrailing != null
                            ? widget.itemTrailing!(item)
                            : (isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null),
                        onTap: () {
                          Navigator.pop(context, item);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
