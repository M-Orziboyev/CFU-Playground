/*
 * Copyright 2021 The CFU-Playground Authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include "menu.h"


#include <stdio.h>
#include <string.h>

#include "playground_util/console.h"
int CHAR_COUNTER = 0;
namespace {

// Print the whole menu
void menu_print(struct Menu* menu) {
  char underline[80];
  size_t title_len = strlen(menu->title);
  memset(underline, '=', title_len);
  underline[title_len] = '\0';

  printf("\n%s\n%s\n", menu->title, underline);
  for (struct MenuItem* p = menu->items; p->selection; p++) {
    printf(" %c: %s\n", p->selection, p->description);
  }
  printf("%s> ", menu->prompt);
}

// Get the menu selection
struct MenuItem* menu_get_selection(struct Menu* menu) {
  char c = '\0';
  //do {
  //  c = readchar();
  //} while (c == '\n' || c == '\r');
  if (CHAR_COUNTER == 0 || CHAR_COUNTER == 1) c = 49; // ASCII value of '1'
  else if (CHAR_COUNTER == 2) c = 103; // ASCII value of 'g'
  else return NULL; 
  CHAR_COUNTER++;
  putchar(c);
  for (struct MenuItem* p = menu->items; p->selection; p++) {
    if (c == p->selection) {
      putchar('\n');
      return p;
    }
  }
  printf(" *unknown*\n");
  return NULL;
}

}; // anonymous namespace

// Run a menu
extern "C" void menu_run(struct Menu* menu) {
  bool exit_now = false;

  while (!exit_now) {
    menu_print(menu);
    struct MenuItem* item = menu_get_selection(menu);
    if (item != NULL) {
      if (item->exit) {
        exit_now = true;
      } else {
        printf("\nRunning %s\n", item->description);
        item->fn();
        puts("---");
      }
    }
    else {
        exit_now = true;
    }
  }
}
