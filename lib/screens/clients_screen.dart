import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/theme.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});
  @override State<ClientsScreen> createState() => _ClientsState();
}

class _ClientsState extends State<ClientsScreen> {
  List _clients = [];
  bool _loading = true;

  @override void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final r = await AdminApi.getClients();
    if (!mounted) return;
    setState(() { _clients = r["clients"] ?? []; _loading = false; });
  }

  String _getId(Map c) => (c["_id"] ?? c["id"] ?? "").toString().replaceAll("ObjectId(", "").replaceAll(")", "").replaceAll("'", "").trim();

  @override
  Widget build(BuildContext context) => _loading
    ? const Center(child: CircularProgressIndicator(color: AdminTheme.cyan))
    : RefreshIndicator(onRefresh: _load, color: AdminTheme.cyan,
        child: _clients.isEmpty
          ? const Center(child: Text("No hay clientes", style: TextStyle(color: AdminTheme.textSecondary)))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _clients.length,
              itemBuilder: (ctx, i) {
                final c = _clients[i];
                final id = _getId(c);
                final blocked = c["blocked"] == true;
                return Card(
                  color: AdminTheme.surface,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: blocked ? AdminTheme.red : AdminTheme.cyan, child: Icon(blocked ? Icons.block : Icons.person, color: Colors.black, size: 18)),
                    title: Text(c["email"] ?? "", style: const TextStyle(color: Colors.white, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text("Vence: ${c["subscription_end"] ?? "N/A"}", style: TextStyle(color: blocked ? AdminTheme.red : AdminTheme.textSecondary, fontSize: 11)),
                    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(icon: Icon(blocked ? Icons.lock_open : Icons.lock_outline, color: blocked ? AdminTheme.green : AdminTheme.gold, size: 20),
                        onPressed: () async { await AdminApi.updateClient(id, blocked: !blocked); _load(); }),
                      IconButton(icon: const Icon(Icons.delete_outline, color: AdminTheme.red, size: 20),
                        onPressed: () async { await AdminApi.deleteClient(id); _load(); }),
                    ]),
                  ),
                );
              }));
}
