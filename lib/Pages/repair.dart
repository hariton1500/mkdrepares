// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mkdrepares/Pages/editrep.dart';
import 'package:mkdrepares/Widgets/all.dart';
import 'package:mkdrepares/globals.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class RepairCard extends StatelessWidget {
  final Map<String, dynamic> repair;
  final PostgrestFilterBuilder<List<Map<String, dynamic>>> fpics;
  final int showStatus;
  final VoidCallback onUpdate;

  const RepairCard({
    super.key,
    required this.repair,
    required this.fpics,
    required this.showStatus,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final sb = Supabase.instance.client;
    final statusColor = statusColors[repair['status_id']];
    final statusText = statuses[repair['status_id']];
    final hasActor = repair['actor'].toString().isNotEmpty;
    final actorName = repair['actor'].toString();
    final createdAt = DateFormat('dd.MM.yyyy')
        .format(DateTime.parse(repair['created_at']));

    return Card(
      elevation: 3,
      margin: EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с адресом и статусом
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                // Статус бейдж
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(width: 12),
                // Адрес
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                          SizedBox(width: 4),
                          showMkdById(repair['mkd_id']),
                        ],
                      ),
                    ],
                  ),
                ),
                // Дата создания
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade600),
                    SizedBox(width: 4),
                    Text(
                      createdAt,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Основное содержимое
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Информация об исполнителе
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: hasActor ? Colors.blue.shade50 : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: hasActor ? Colors.blue.shade200 : Colors.orange.shade200,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasActor ? Icons.person : Icons.person_outline,
                        size: 20,
                        color: hasActor ? Colors.blue.shade700 : Colors.orange.shade700,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: hasActor
                            ? Text(
                                'Исполнитель: ${actorName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.blue.shade900,
                                ),
                              )
                            : Text(
                                'Исполнитель не назначен',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.orange.shade900,
                                ),
                              ),
                      ),
                      if (repair['actor'].toString().isEmpty && activeUser['level'] > 5)
                        TextButton.icon(
                          onPressed: () async {
                            await sb
                                .from('repairs')
                                .update({'actor': activeUser['login']})
                                .eq('id', repair['id'])
                                .limit(1)
                                .select();
                            onUpdate();
                          },
                          icon: Icon(Icons.person_add, size: 16),
                          label: Text('Назначить себе'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      if (repair['actor'].toString().isEmpty && activeUser['level'] <= 5)
                        TextButton.icon(
                          onPressed: () => _showActorSelector(context, sb, repair),
                          icon: Icon(Icons.person_add, size: 16),
                          label: Text('Назначить'),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            minimumSize: Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      if (repair['actor'].toString().isNotEmpty && activeUser['level'] <= 5)
                        IconButton(
                          icon: Icon(Icons.edit, size: 18),
                          onPressed: () => _showActorSelector(context, sb, repair),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                          tooltip: 'Изменить исполнителя',
                        ),
                    ],
                  ),
                ),
                
                SizedBox(height: 16),
                
                // Кнопки действий
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (activeUser['level'] <= 5)
                      _ActionChip(
                        icon: Icons.warning_amber_rounded,
                        label: 'Рекламация',
                        color: Colors.red,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => EditRep(
                              repair: repair,
                              name: 'reclamation',
                            ),
                          ).then((onValue) => onUpdate());
                        },
                      ),
                    if (activeUser['level'] <= 5 || activeUser['login'] == repair['actor'])
                      _ActionChip(
                        icon: Icons.description,
                        label: 'Отчет',
                        color: Colors.blue,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => EditRep(
                              repair: repair,
                              name: 'report',
                            ),
                          ).then((onValue) => onUpdate());
                        },
                      ),
                    if (activeUser['level'] <= 5)
                      _ActionChip(
                        icon: Icons.flag,
                        label: 'Статус',
                        color: Colors.green,
                        onTap: () => _showStatusSelector(context, sb, repair),
                      ),
                  ],
                ),
                
                SizedBox(height: 16),
                
                // Входные данные
                _InfoSection(
                  icon: Icons.info_outline,
                  title: 'Входные данные',
                  content: repair['creater_comment'].toString(),
                  imagesFuture: fpics.eq('creator_flag', 1),
                ),
                
                if (repair['reclamation'].toString().isNotEmpty) ...[
                  SizedBox(height: 12),
                  Divider(height: 1),
                  SizedBox(height: 12),
                  _InfoSection(
                    icon: Icons.warning_amber_rounded,
                    title: 'Рекламация',
                    content: repair['reclamation'].toString(),
                    imagesFuture: fpics.eq('reclamation_flag', 1),
                    color: Colors.red,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showActorSelector(
    BuildContext context,
    dynamic sb,
    Map<String, dynamic> repair,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите исполнителя',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(user[0].toUpperCase()),
                      backgroundColor: Colors.blue.shade100,
                    ),
                    title: Text(user),
                    onTap: () async {
                      await sb
                          .from('repairs')
                          .update({'actor': user})
                          .eq('id', repair['id'])
                          .limit(1)
                          .select();
                      onUpdate();
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStatusSelector(
    BuildContext context,
    dynamic sb,
    Map<String, dynamic> repair,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите статус',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: statuses.length,
                itemBuilder: (context, index) {
                  final status = statuses[index];
                  final isSelected = repair['status_id'] == index;
                  return ListTile(
                    leading: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: statusColors[index],
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(status),
                    trailing: isSelected ? Icon(Icons.check, color: Colors.green) : null,
                    onTap: () async {
                      await sb
                          .from('repairs')
                          .update({'status_id': index})
                          .eq('id', repair['id'])
                          .limit(1)
                          .select();
                      onUpdate();
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  final Future? imagesFuture;
  final Color? color;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.content,
    this.imagesFuture,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final defaultColor = Colors.grey.shade700;
    final sectionColor = color ?? defaultColor;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: sectionColor),
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: sectionColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Container(
                padding: EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Text(
                    content.isEmpty ? 'Нет данных' : content,
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            );
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Text(
              content.isEmpty ? 'Нет данных' : content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ),
        if (imagesFuture != null) ...[
          SizedBox(height: 8),
          showPics(imagesFuture),
        ],
      ],
    );
  }
}
