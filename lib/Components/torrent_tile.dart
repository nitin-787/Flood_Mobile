import 'package:duration/duration.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:flood_mobile/Api/torrent_api.dart';
import 'package:flood_mobile/Components/add_tag_dialogue.dart';
import 'package:flood_mobile/Components/delete_torrent_sheet.dart';
import 'package:flood_mobile/Constants/theme_provider.dart';
import 'package:flood_mobile/Model/torrent_model.dart';
import 'package:flood_mobile/Provider/multiple_select_torrent_provider.dart';
import 'package:flood_mobile/Route/Arguments/torrent_content_page_arguments.dart';
import 'package:flood_mobile/Route/routes.dart';
import 'package:flood_mobile/Services/date_converter.dart';
import 'package:flood_mobile/Services/file_size_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:focused_menu/modals.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';
import 'flood_snackbar.dart';

class TorrentTile extends StatefulWidget {
  final TorrentModel model;
  final int themeIndex;
  final List<int> indexes;

  TorrentTile(
      {required this.model, required this.themeIndex, required this.indexes});

  @override
  _TorrentTileState createState() => _TorrentTileState();
}

class _TorrentTileState extends State<TorrentTile> {
  bool isExpanded = false;

  void deleteTorrent() {
    showModalBottomSheet(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15),
          topLeft: Radius.circular(15),
        ),
      ),
      isScrollControlled: true,
      context: context,
      backgroundColor:
          ThemeProvider.theme(widget.themeIndex).scaffoldBackgroundColor,
      builder: (context) {
        return DeleteTorrentSheet(
          torrents: [widget.model],
          themeIndex: widget.themeIndex,
          indexes: widget.indexes,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double hp = MediaQuery.of(context).size.height;
    double wp = MediaQuery.of(context).size.width;
    return Consumer<MultipleSelectTorrentProvider>(
        builder: (context, selectTorrent, child) {
      return Row(
        children: [
          if (selectTorrent.isSelectionMode)
            GestureDetector(
              onTap: () {
                if (selectTorrent.selectedTorrentList
                    .any((element) => element.hash == widget.model.hash)) {
                  selectTorrent.removeItemFromList(widget.model);
                } else {
                  selectTorrent.addItemToList(widget.model);
                }
              },
              child: Container(
                width: 30,
                height: 90,
                color: Colors.transparent,
                padding: EdgeInsets.only(left: 15),
                child: Center(
                  child: Checkbox(
                    activeColor:
                        ThemeProvider.theme(widget.themeIndex).primaryColorDark,
                    value: selectTorrent.selectedTorrentList
                        .any((element) => element.hash == widget.model.hash),
                    onChanged: (bool? value) {
                      if (value!) {
                        selectTorrent.addItemToList(widget.model);
                        selectTorrent.addIndexToList(widget.indexes);
                      } else {
                        selectTorrent.removeItemFromList(widget.model);
                        selectTorrent.removeIndexFromList(widget.indexes);
                      }
                    },
                  ),
                ),
              ),
            ),
          Expanded(
            child: Slidable(
              actionPane: SlidableBehindActionPane(),
              actionExtentRatio: 0.25,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: FocusedMenuHolder(
                  key: Key('Long Press Torrent Tile Menu'),
                  menuBoxDecoration: BoxDecoration(
                      color: ThemeProvider.theme(widget.themeIndex)
                          .textTheme
                          .bodyLarge
                          ?.color,
                      borderRadius: BorderRadius.circular(50)),
                  menuWidth: MediaQuery.of(context).size.width * 0.5,
                  menuItemExtent: 60,
                  onPressed: () {},
                  menuItems: [
                    FocusedMenuItem(
                      title: Text(
                        selectTorrent.isSelectionMode
                            ? 'Unselect Torrent'
                            : 'Select Torrent',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      trailingIcon: Icon(
                        FontAwesomeIcons.solidFile,
                        color: Colors.black,
                        size: 18,
                      ),
                      onPressed: () {
                        selectTorrent.changeSelectionMode();
                        selectTorrent.removeAllItemsFromList();
                        selectTorrent.removeAllIndexFromList();
                        selectTorrent.addItemToList(widget.model);
                        selectTorrent.addIndexToList(widget.indexes);
                      },
                    ),
                    FocusedMenuItem(
                      title: Text(
                        'Set Tags',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      trailingIcon: Icon(
                        FontAwesomeIcons.tags,
                        color: Colors.black,
                        size: 18,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AddTagDialogue(
                            torrents: [widget.model],
                            index: widget.themeIndex,
                          ),
                        );
                      },
                    ),
                    FocusedMenuItem(
                      title: Text(
                        'Check Hash',
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                      trailingIcon: Icon(
                        Icons.tag,
                        color: Colors.black,
                      ),
                      onPressed: () async {
                        var result = await TorrentApi.checkTorrentHash(
                            hashes: [widget.model.hash], context: context);
                        if (result) {
                          if (kDebugMode)
                            print("check hash performed successfully");
                          final addTorrentSnackbar = addFloodSnackBar(
                              SnackbarType.success,
                              'Hash check successful',
                              'Dismiss');

                          ScaffoldMessenger.of(context)
                              .showSnackBar(addTorrentSnackbar);
                        } else {
                          if (kDebugMode) print("Error check hash failed");
                          final addTorrentSnackbar = addFloodSnackBar(
                              SnackbarType.caution,
                              'Torrent hash failed',
                              'Dismiss');

                          ScaffoldMessenger.of(context)
                              .showSnackBar(addTorrentSnackbar);
                        }
                      },
                    ),
                    FocusedMenuItem(
                      backgroundColor: Colors.redAccent,
                      title: Text(
                        'Delete',
                      ),
                      trailingIcon: Icon(
                        Icons.delete,
                        color: ThemeProvider.theme(widget.themeIndex)
                            .textTheme
                            .bodyLarge
                            ?.color,
                      ),
                      onPressed: () {
                        deleteTorrent();
                      },
                    ),
                  ],
                  child: ExpansionTileCard(
                    key: Key(widget.model.hash),
                    onExpansionChanged: (value) {
                      setState(() {
                        isExpanded = value;
                      });
                    },
                    elevation: 0,
                    expandedColor:
                        ThemeProvider.theme(widget.themeIndex).primaryColor,
                    baseColor:
                        ThemeProvider.theme(widget.themeIndex).primaryColor,
                    expandedTextColor: ThemeProvider.theme(widget.themeIndex)
                        .colorScheme
                        .secondary,
                    title: ListTile(
                      key: Key(widget.model.hash),
                      contentPadding: EdgeInsets.all(0),
                      title: Text(
                        widget.model.name,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ThemeProvider.theme(widget.themeIndex)
                              .textTheme
                              .bodyLarge
                              ?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: LinearPercentIndicator(
                                    key: Key('Linear Progress Indicator'),
                                    padding: EdgeInsets.all(0),
                                    lineHeight: 5.0,
                                    percent: widget.model.percentComplete
                                            .roundToDouble() /
                                        100,
                                    backgroundColor:
                                        ThemeProvider.theme(widget.themeIndex)
                                            .colorScheme
                                            .secondary
                                            .withAlpha(80),
                                    progressColor: (widget.model.percentComplete
                                                .toStringAsFixed(1) ==
                                            '100.0')
                                        ? ThemeProvider.theme(widget.themeIndex)
                                            .primaryColorDark
                                        : Colors.blue,
                                  ),
                                ),
                                SizedBox(
                                  width: 30,
                                ),
                                Text(widget.model.percentComplete
                                        .toStringAsFixed(1) +
                                    " %"),
                              ],
                            ),
                            SizedBox(
                              height: hp * 0.01,
                            ),
                            Row(
                              children: [
                                Text(
                                  (widget.model.status.contains('downloading'))
                                      ? 'Downloading  '
                                      : 'Stopped  ',
                                  key: Key('status widget'),
                                  style: TextStyle(
                                    color:
                                        ThemeProvider.theme(widget.themeIndex)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    (widget.model.eta.toInt() != -1)
                                        ? ('ETA: ') +
                                            prettyDuration(
                                                Duration(
                                                  seconds:
                                                      widget.model.eta.toInt(),
                                                ),
                                                abbreviated: true)
                                        : 'ETA : ∞',
                                    overflow: TextOverflow.ellipsis,
                                    key: Key('eta widget'),
                                    style: TextStyle(
                                        color: ThemeProvider.theme(
                                                widget.themeIndex)
                                            .textTheme
                                            .bodyLarge
                                            ?.color),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: hp * 0.002,
                            ),
                            Row(
                              key: Key('download done data widget'),
                              children: [
                                Text(
                                  filesize(widget.model.bytesDone.toInt()),
                                  style: TextStyle(
                                    color:
                                        ThemeProvider.theme(widget.themeIndex)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                  ),
                                ),
                                Text(' / '),
                                Text(
                                  filesize(widget.model.sizeBytes.toInt()),
                                  style: TextStyle(
                                    color:
                                        ThemeProvider.theme(widget.themeIndex)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        (widget.model.status.contains('downloading'))
                            ? GestureDetector(
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color:
                                        ThemeProvider.theme(widget.themeIndex)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    Icons.stop,
                                    color:
                                        ThemeProvider.theme(widget.themeIndex)
                                            .primaryColor,
                                  ),
                                ),
                                onTap: () {
                                  TorrentApi.stopTorrent(
                                      context: context,
                                      hashes: [widget.model.hash]);
                                },
                              )
                            : GestureDetector(
                                child: Container(
                                  width: 30,
                                  height: 30,
                                  decoration: BoxDecoration(
                                    color:
                                        ThemeProvider.theme(widget.themeIndex)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color:
                                        ThemeProvider.theme(widget.themeIndex)
                                            .primaryColor,
                                  ),
                                ),
                                onTap: () {
                                  TorrentApi.startTorrent(
                                      context: context,
                                      hashes: [widget.model.hash]);
                                },
                              ),
                        (!isExpanded)
                            ? Icon(
                                Icons.keyboard_arrow_down_rounded,
                              )
                            : Icon(
                                Icons.keyboard_arrow_up_rounded,
                              ),
                      ],
                    ),
                    children: [
                      Card(
                        color: ThemeProvider.theme(widget.themeIndex)
                            .primaryColorLight,
                        child: Padding(
                          padding: EdgeInsets.all(15),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: double.infinity,
                              ),
                              Text(
                                'General',
                                style: TextStyle(
                                    color:
                                        ThemeProvider.theme(widget.themeIndex)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: hp * 0.01,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Date Added'),
                                  Text(dateConverter(
                                      timestamp:
                                          widget.model.dateAdded.toInt())),
                                ],
                              ),
                              SizedBox(
                                height: hp * 0.005,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Date Created'),
                                  Text(dateConverter(
                                      timestamp:
                                          widget.model.dateCreated.toInt())),
                                ],
                              ),
                              SizedBox(
                                height: hp * 0.005,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Location'),
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.only(left: wp * 0.1),
                                      child: Text(widget.model.directory),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: hp * 0.005,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Tags',
                                  ),
                                  Flexible(
                                    child: Container(
                                      padding: EdgeInsets.only(left: wp * 0.17),
                                      child: Text(
                                          (widget.model.tags.length != 0)
                                              ? widget.model.tags
                                                  .toList()
                                                  .toString()
                                              : 'None'),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: hp * 0.03,
                              ),
                              Text(
                                'Transfer',
                                style: TextStyle(
                                    color:
                                        ThemeProvider.theme(widget.themeIndex)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: hp * 0.01,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Peers'),
                                  Text(widget.model.peersConnected
                                          .toInt()
                                          .toString() +
                                      ' connected of ' +
                                      widget.model.peersTotal
                                          .toInt()
                                          .toString()),
                                ],
                              ),
                              SizedBox(
                                height: hp * 0.005,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Seeds'),
                                  Text(widget.model.seedsConnected
                                          .toInt()
                                          .toString() +
                                      ' connected of ' +
                                      widget.model.seedsTotal
                                          .toInt()
                                          .toString()),
                                ],
                              ),
                              SizedBox(
                                height: hp * 0.03,
                              ),
                              Text(
                                'Torrent',
                                style: TextStyle(
                                    color:
                                        ThemeProvider.theme(widget.themeIndex)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: hp * 0.01,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Size'),
                                  Text(
                                      filesize(widget.model.sizeBytes.toInt())),
                                ],
                              ),
                              SizedBox(
                                height: hp * 0.005,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Type',
                                  ),
                                  Text(widget.model.isPrivate
                                      ? 'Private'
                                      : 'Public'),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: double.infinity,
                                height: 60,
                                child: OutlinedButton(
                                  key: Key('Files button'),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                        Routes.torrentContentScreenRoute,
                                        arguments: TorrentContentPageArguments(
                                            hash: widget.model.hash,
                                            directory: widget.model.directory,
                                            index: widget.themeIndex));
                                  },
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0)),
                                    side: BorderSide(
                                      width: 1.0,
                                      color:
                                          ThemeProvider.theme(widget.themeIndex)
                                              .textTheme
                                              .bodyLarge!
                                              .color!,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.file_copy_rounded,
                                        color: ThemeProvider.theme(
                                                widget.themeIndex)
                                            .textTheme
                                            .bodyLarge
                                            ?.color,
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      Text(
                                        "Files",
                                        style: TextStyle(
                                          color: ThemeProvider.theme(
                                                  widget.themeIndex)
                                              .textTheme
                                              .bodyLarge
                                              ?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              secondaryActions: <Widget>[
                IconSlideAction(
                  caption: 'Delete',
                  color: Colors.redAccent,
                  icon: Icons.delete,
                  onTap: () {
                    deleteTorrent();
                  },
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}
