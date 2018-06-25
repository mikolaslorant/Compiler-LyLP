#ifndef NODE_H
#define NODE_H

#define INTEGER 0
#define STRING 1

typedef struct Node {
	int type;
	char* string;
}Node;


Node* newNode(int type, char* string);

#endif