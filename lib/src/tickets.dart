import 'package:open_polito_api/src/constants.dart';
import 'package:open_polito_api/src/device.dart';
import 'package:open_polito_api/src/utils.dart';

/// A support ticket.
class Ticket {
  final int? id;
  final String? title;

  /// The HTML text of the first message
  final String? description;

  /// The date when this ticket was opened, as Unix epoch
  final int? creationDate;

  /// The date when this ticket was last updated, as Unix epoch
  final int? lastUpdated;

  /// A number representing the state of the ticket. 1 = open, 2 = closed
  final int? state;

  /// The number of unread messages in the ticket thread
  final int? unread;

  const Ticket({
    this.id,
    this.title,
    this.description,
    this.creationDate,
    this.lastUpdated,
    this.state,
    this.unread,
  });
}

Ticket parseTicket(dynamic data) {
  return Ticket(
    id: data["id"],
    title: data["oggetto"],
    description: data["descrizione"],
    creationDate: data["dataApertura"],
    lastUpdated: data["dataAggiornamento"],
    state: data["idStato"],
    unread: data["countnonlette"],
  );
}

/// Returns the list of tickets for the user.
Future<List<Ticket>> getTickets(Device device) async {
  var data = await device.post(ticketRoute, {
    "operazione": "getListaTicket",
  });
  checkError(data);

  var ticketsData = data.data?["ticket"];

  if (ticketsData == null) return [];

  return ticketsData.map<Ticket>(parseTicket).toList();
}

/// Returns details about the given ticket id [ticketId].
Future<Ticket> getTicket(Device device, int ticketId) async {
  var data = await device.post(ticketRoute, {
    "operazione": "getTicket",
    "id_ticket": ticketId,
  });
  checkError(data);
  return parseTicket(data.data?["ticket"]);
}

/// Posts a message in a ticket thread.
///
/// [ticketId] is the id of the ticket.
/// [text] is the HTML text of the reply (must use <br> for newlines).
Future<void> replyToTicket(Device device, int ticketId, String text) async {
  var data = await device.post(ticketRoute, {
    "operazione": "sendRisposta",
    "testo": text,
    "id_ticket": ticketId,
  });
  checkError(data);
}
