#include <stdio.h>
#include <stdlib.h>
#include "node.h"

Node* newNode(int type, char* string)
{
	Node* node = malloc(sizeof(Node));
	node->type = type;
	node->string = string;
	return node;
}
