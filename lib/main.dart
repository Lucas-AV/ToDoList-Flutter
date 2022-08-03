import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

const todoListKey = 'todo_list';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TodoListPage(),
    );
  }
}

class TodoListPage extends StatefulWidget {
  TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => _TodoListPageState();
}

class _TodoListPageState extends State<TodoListPage> {
  final TextEditingController todoController = TextEditingController();
  final TextEditingController todoController2 = TextEditingController();
  final TodoRepository todoRepository = TodoRepository();
  List<Todo> todos = [];
  List<Todo> tempTodos = [];
  Todo? deletedTodo;
  int? deletedTodoPos;

  @override
  void initState(){
    super.initState();
    todoRepository.getTodoList().then((value){
      setState(() {
        todos = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16,16,16,10),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextField(
                            controller: todoController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Insira um título",
                              hintText: "Ex. Aprender algo novo",
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xff00d7f3),
                                  width: 2
                                )
                              ),
                              labelStyle: TextStyle(
                                  color: Color(0xff00d7f3)
                              )
                            ),
                          ),
                          SizedBox(height: 8),
                          TextField(
                            controller: todoController2,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Insira uma descrição",
                                hintText: "Descrição da atividade",
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xff00d7f3),
                                        width: 2
                                    )
                                ),
                                labelStyle: TextStyle(
                                    color: Color(0xff00d7f3)
                                )
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Column(
                      children: [
                        ElevatedButton(
                            onPressed: (){
                              String text = todoController.text;
                              String text2 = todoController2.text;
                              setState(() {
                                if(text.isEmpty){
                                  onTitleError();
                                }
                                else {
                                  if(text2.isEmpty){
                                    text2 = "Sem descrição";
                                  }
                                  Todo newTodo = Todo(
                                      id: todos.length.toInt(),
                                      title: text,
                                      complete: false,
                                      description: text2,
                                      dateTime: DateTime.now()
                                  );
                                  todos.add(newTodo);
                                }
                              });
                              todoController.clear();
                              todoController2.clear();
                              todoRepository.saveTodoList(todos);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xff00d7f3),
                              padding: EdgeInsets.only(top: 9,bottom: 9),
                            ),
                            child: Icon(Icons.add, size: 50)
                        ),
                        SizedBox(height: 6),
                        ElevatedButton(
                          onPressed: (){
                            setState(() {
                              todoController.clear();
                              todoController2.clear();
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.red,
                            padding: EdgeInsets.only(top: 5,bottom: 5),
                          ),
                          child: Icon(Icons.close, size: 40)
                        ),
                      ],
                    )
                  ],
                ),
                SizedBox(height: 10),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for(Todo todo in todos)
                        TodoListItem(
                          todo: todo,
                          onDelete: onDelete,
                        )
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: Row(
                    children: [
                      Expanded(
                          child: todos.length > 1 ?
                          Text("Existem ${todos.length} tarefas registradas aqui",style: TextStyle(fontSize: 15)) :
                          todos.isNotEmpty ?
                          Text("Existe ${todos.length} tarefa registrada aqui",style: TextStyle(fontSize: 15)) :
                          Text("Nenhuma tarefa foi registrada aqui",style: TextStyle(fontSize: 15))
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Color(0xff00d7f3),
                          padding: EdgeInsets.all(16)
                        ),
                        onPressed: showDeleteTodosConfirmationDialog,
                        child: Text("Limpar tudo")
                      )
                    ],
                  ),
                ),
              ]
            )
          ),
        )
      ),
    );
  }

  void onTitleError(){
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'O título da tarefa não pode estar vazio!',
          style: TextStyle(
            color: Color(0xff060708),
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void onDelete(Todo todo){
    deletedTodo = todo;
    deletedTodoPos = todos.indexOf(todo);

    setState(() {
      todos.remove(todo);
    });
    todoRepository.saveTodoList(todos);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'A tarefa ${todo.title} foi removida com sucesso!',
          style: TextStyle(
            color: Color(0xff060708)
          ),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: const Color(0xff00d7f3),
          onPressed: (){
            setState(() {
              todos.add(deletedTodo!);
            });
            todoRepository.saveTodoList(todos);
            deletedTodo = null;
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void showDeleteTodosConfirmationDialog(){
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Limpar tudo?'),
        content: Text("Você tem certeza que deseja apagar todas as tarefas?"),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(primary: Color(0xff00d7f3)),
            child: Text('Cancelar')
          ),
          TextButton(
              onPressed: (){
                Navigator.of(context).pop();
                deleteAllTodos();
              },
              style: TextButton.styleFrom(primary: Colors.red),
              child: Text('Limpar tudo')
          ),
        ],
      )
    );
  }

  void deleteAllTodos(){
    setState(() {
      tempTodos.addAll(todos);
      todos.clear();
      todoRepository.clearTodoList();
    });

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'A lista de tarefas foi limpa!',
          style: TextStyle(
              color: Color(0xff060708)
          ),
        ),
        backgroundColor: Colors.white,
        action: SnackBarAction(
          label: 'Desfazer',
          textColor: const Color(0xff00d7f3),
          onPressed: (){
            setState(() {
              todos.addAll(tempTodos);
              tempTodos.clear();
            });
            todoRepository.saveTodoList(todos);
          },
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class TodoListItem extends StatefulWidget {
  const TodoListItem({
    Key? key,
    required this.todo, required this.onDelete,
  }) : super(key: key);

  final Todo todo;
  final Function(Todo) onDelete;
  @override
  State<TodoListItem> createState() => _TodoListItemState();
}

class _TodoListItemState extends State<TodoListItem> {
  List<String> weekdays = [" ","SEG","TER","QUA","QUI","SEX","SÁB","DOM"];
  List<String> months = ["Jan","Fev","Mar","Abr","Mai","Jun","Jul","Ago","Set","Out","Nov","Dez"];
  TextEditingController editDescriptionController = TextEditingController();
  TextEditingController editTitleController = TextEditingController();
  String? editTitle, editDescription;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.5),
      child: Slidable(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3,vertical: 3),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: Offset(0, 1), // changes position of shadow
                ),
              ],
            ),
            child: MaterialButton(
              padding: EdgeInsets.zero,
              onPressed: (){
                showEditDialog();
              },
              child: Row(
                children: [
                  SizedBox(width: 10,height: 85),
                  MaterialButton(
                    color: Color(0xff00d7f3),
                    padding: EdgeInsets.fromLTRB(6, 6, 6, 6),
                    minWidth: 70,
                    height: 70,
                    onPressed: (){
                      setState(() {
                        showDatePicker(
                          context: context,
                          initialDate: widget.todo.dateTime,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2200),
                        ).then((date) {
                          setState(() {
                            widget.todo.dateTime = date!;
                          });
                        });
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          weekdays[widget.todo.dateTime.weekday],
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                          ),
                        ),
                        Text(
                          "${widget.todo.dateTime.day.toString()} ${months[widget.todo.dateTime.month-1]}.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.todo.title,
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          widget.todo.description,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black26
                          ),
                        ),
                        SizedBox(height: 3),
                      ],
                    ),
                  ),
                  RawMaterialButton(
                    onPressed: () {
                      setState(() {
                        widget.todo.complete == true ?
                        widget.todo.complete = false :
                        widget.todo.complete = true;
                      });
                    },
                    child: widget.todo.complete == true ?
                    Icon(Icons.check_circle,size: 45,color: Color(0xff00d7f3)) :
                    Icon(Icons.check_circle_outline,size: 45,color: Colors.black12),
                    shape: CircleBorder(),
                  ),
                ],
              ),
            ),
          ),
        ),
        actionPane: const SlidableStrechActionPane(),
        actionExtentRatio: 0.20,
        secondaryActions: [
          IconSlideAction(
            color: Colors.red,
            icon: Icons.delete,
            caption: 'Deletar',
            onTap: (){
              widget.onDelete(widget.todo);
            },
          ),
        ],
      ),
    );
  }

  void showEditDialog(){
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Editar conteúdo da tarefa'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editTitleController,
                decoration: InputDecoration(
                  hintText: "Título: ${widget.todo.title}",
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xff00d7f3),
                          width: 2
                      )
                  ),
                  labelStyle: TextStyle(
                      color: Colors.black12
                  )
                ),
              ),
              SizedBox(height: 4),
              TextField(
                controller: editDescriptionController,
                decoration: InputDecoration(
                  hintText: "Descrição: ${widget.todo.description}",
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                          color: Color(0xff00d7f3),
                          width: 2
                      )
                  ),
                  labelStyle: TextStyle(
                      color: Colors.black12
                  )
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: (){
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(primary: Colors.red),
                child: Text('Cancelar')
            ),
            TextButton(
                onPressed: (){
                  setState(() {
                    editDescriptionController.text.length.toInt() > 0 ?
                    widget.todo.description = editDescriptionController.text :
                    widget.todo.description = widget.todo.description;
                    editTitleController.text.length.toInt() > 0 ?
                    widget.todo.title = editTitleController.text :
                    widget.todo.title = widget.todo.title;
                  });
                  Navigator.of(context).pop();
                },
                style: TextButton.styleFrom(primary: Color(0xff00d7f3)),
                child: Text('Aplicar')
            ),
          ],
        )
    );
  }
}

class Todo {
  Todo({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.complete,
    required this.id
  });
  String title, description;
  DateTime dateTime;
  bool complete;
  int id;

  Todo.fromJson(Map<String, dynamic> json):
    title = json['title'],
    description = json['description'],
    complete = json['complete'],
    dateTime = DateTime.parse(json['datetime']),
    id = json['id'];

  Map<String, dynamic> toJson(){
    return {
      'id':id,
      'title':title,
      'description':description,
      'complete':complete,
      'datetime':dateTime.toIso8601String(),
    };
  }
}

class TodoRepository{
  TodoRepository(){
    SharedPreferences.getInstance().then((value) => sharedPreferences = value);
  }
  late SharedPreferences sharedPreferences;

  Future<List<Todo>> getTodoList() async{
    sharedPreferences = await SharedPreferences.getInstance();
    final String jsonString = sharedPreferences.getString(todoListKey) ?? '[]';
    final List jsonDecoded = json.decode(jsonString) as List;
    return jsonDecoded.map((e) => Todo.fromJson(e)).toList();
  }

  void saveTodoList(List<Todo> todos){
    final String jsonString = json.encode(todos);
    sharedPreferences.setString('todo_list', jsonString);
  }

  void clearTodoList(){
    sharedPreferences.setString('todo_list', '');
  }
}