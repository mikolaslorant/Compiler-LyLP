#ifndef NODE_H
#define NODE_H


typedef struct Node {
	int type;
	char* string;
}Node;


Node* newNode(int type, char* string);

#endif