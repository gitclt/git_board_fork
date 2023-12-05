import 'package:board/board_item.dart';
import 'package:board/boardview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef void OnDropList(int? listIndex,int? oldListIndex);
typedef void OnTapList(int? listIndex);
typedef void OnStartDragList(int? listIndex);

class BoardList extends StatefulWidget {
  final List<Widget>? header;
  final Widget? footer;
  final List<BoardItem>? items;
  final Color? backgroundColor;
  final Color? headerBackgroundColor;
  final BoardViewState? boardView;
  final OnDropList? onDropList;
  final OnTapList? onTapList;
  final OnStartDragList? onStartDragList;
  final bool draggable;

  const BoardList({
    Key? key,
    this.header,
    this.items,
    this.footer,
    this.backgroundColor,
    this.headerBackgroundColor,
    this.boardView,
    this.draggable = true,
    this.index, this.onDropList, this.onTapList, this.onStartDragList,
  }) : super(key: key);

  final int? index;

  @override
  State<StatefulWidget> createState() {
    return BoardListState();
  }
}

class BoardListState extends State<BoardList> with AutomaticKeepAliveClientMixin{
  List<BoardItemState> itemStates = [];
  ScrollController boardListController = new ScrollController();

  void onDropList(int? listIndex) {
    if(widget.onDropList != null){
      widget.onDropList!(listIndex,widget.boardView!.startListIndex);
    }
    widget.boardView!.draggedListIndex = null;
    if(widget.boardView!.mounted) {
      widget.boardView!.setState(() {

      });
    }
  }

  void _startDrag(Widget item, BuildContext context) {
    if (widget.boardView != null && widget.draggable) {
      if(widget.onStartDragList != null){
        widget.onStartDragList!(widget.index);
      }
      widget.boardView!.startListIndex = widget.index;
      widget.boardView!.height = context.size!.height;
      widget.boardView!.draggedListIndex = widget.index!;
      widget.boardView!.draggedItemIndex = null;
      widget.boardView!.draggedItem = item;
      widget.boardView!.onDropList = onDropList;
      widget.boardView!.run();
      if(widget.boardView!.mounted) {
        widget.boardView!.setState(() {});
      }
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    List<Widget> listWidgets = [];
    if (widget.header != null) {
      Color? headerBackgroundColor = Theme.of(context).colorScheme.outlineVariant.withOpacity(0.4);
      if (widget.headerBackgroundColor != null) {
        headerBackgroundColor = widget.headerBackgroundColor;
      }
      listWidgets.add(GestureDetector(
          onTap: (){
            if(widget.onTapList != null){
              widget.onTapList!(widget.index);
            }
          },
          onTapDown: (otd) {
            if(widget.draggable) {
              RenderBox object = context.findRenderObject() as RenderBox;
              Offset pos = object.localToGlobal(Offset.zero);
              widget.boardView!.initialX = pos.dx;
              widget.boardView!.initialY = pos.dy;

              widget.boardView!.rightListX = pos.dx + object.size.width;
              widget.boardView!.leftListX = pos.dx;
            }
          },
          onTapCancel: () {},
          onLongPress: () {
            if(!widget.boardView!.widget.isSelecting && widget.draggable) {
              _startDrag(widget, context);
            }
          },
          child: Container(
            decoration: BoxDecoration(color: headerBackgroundColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.header!),
          )));

    }
    if (widget.items != null) {
      listWidgets.add(Flexible(
          fit: FlexFit.tight,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(),
            controller: boardListController,
            itemCount: widget.items!.length,
            itemBuilder: (ctx, index) {
              if (widget.items![index].boardList == null ||
                  widget.items![index].index != index ||
                  widget.items![index].boardList!.widget.index != widget.index ||
                  widget.items![index].boardList != this) {
                widget.items![index] = BoardItem(
                  boardList: this,
                  item: widget.items![index].item,
                  draggable: widget.items![index].draggable,
                  index: index,
                  onDropItem: widget.items![index].onDropItem,
                  onTapItem: widget.items![index].onTapItem,
                  onDragItem: widget.items![index].onDragItem,
                  onStartDragItem: widget.items![index].onStartDragItem,
                );
              }
              if (widget.boardView!.draggedItemIndex == index &&
                  widget.boardView!.draggedListIndex == widget.index) {
                return Opacity(
                  opacity: 0.0,
                  child: widget.items![index],
                );
              } else {
                return widget.items![index];
              }
            },
          )));
    }

    if (widget.footer != null) {
      listWidgets.add(widget.footer!);
    }

    Color? backgroundColor = Theme.of(context).colorScheme.onInverseSurface;

    if (widget.backgroundColor != null) {
      backgroundColor = widget.backgroundColor;
    }
    if (widget.boardView!.listStates.length > widget.index!) {
      widget.boardView!.listStates.removeAt(widget.index!);
    }
    widget.boardView!.listStates.insert(widget.index!, this);

    return Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: backgroundColor,
          borderRadius: const BorderRadius.all(Radius.circular(8)),

        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: listWidgets,
        ));
  }
}