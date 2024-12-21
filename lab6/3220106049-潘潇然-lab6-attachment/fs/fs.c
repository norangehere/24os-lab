#include "fs.h"

#include "fat32.h"
#include "mm.h"
#include "printk.h"
#include "string.h"
#include "syscall.h"
#include "vfs.h"

struct files_struct *file_init() {
  // todo: alloc pages for files_struct, and initialize stdin, stdout, stderr
  struct files_struct *ret;
  uint64_t size = sizeof(struct files_struct);
  uint64_t pages = (size + PGSIZE - 1) / PGSIZE;
  printk("file_init: size = %d, pages = %d\n", size, pages);
  ret = (struct files_struct *)alloc_pages(pages);

  // stdin
  ret->fd_array[0].opened = 1;
  ret->fd_array[0].perms = 1;
  ret->fd_array[0].cfo = 0;
  ret->fd_array[0].lseek = NULL;
  ret->fd_array[0].write = NULL;
  ret->fd_array[0].read = stdin_read;

  // stdout
  ret->fd_array[1].opened = 1;
  ret->fd_array[1].perms = 2;
  ret->fd_array[1].cfo = 0;
  ret->fd_array[1].lseek = NULL;
  ret->fd_array[1].write = stdout_write;
  ret->fd_array[1].read = NULL;

  // stderr
  ret->fd_array[2].opened = 1;
  ret->fd_array[2].perms = 2;
  ret->fd_array[2].cfo = 0;
  ret->fd_array[2].lseek = NULL;
  ret->fd_array[2].write = stderr_write;
  ret->fd_array[2].read = NULL;

  for (uint64_t i = 3; i < MAX_FILE_NUMBER; i++) ret->fd_array[i].opened = 0;

  return ret;
}

uint32_t get_fs_type(const char *filename) {
  uint32_t ret;
  if (memcmp(filename, "/fat32/", 7) == 0) {
    ret = FS_TYPE_FAT32;
  } else if (memcmp(filename, "/ext2/", 6) == 0) {
    ret = FS_TYPE_EXT2;
  } else {
    ret = -1;
  }
  return ret;
}

int32_t file_open(struct file *file, const char *path, int flags) {
  file->opened = 1;
  file->perms = flags;
  file->cfo = 0;
  file->fs_type = get_fs_type(path);
  memcpy(file->path, path, strlen(path) + 1);

  if (file->fs_type == FS_TYPE_FAT32) {
    file->lseek = fat32_lseek;
    file->write = fat32_write;
    file->read = fat32_read;
    file->fat32_file = fat32_open_file(path);
    // todo: check if fat32_file is valid (i.e. successfully opened) and return
  } else if (file->fs_type == FS_TYPE_EXT2) {
    printk(RED "Unsupport ext2\n" CLEAR);
    return -1;
  } else {
    printk(RED "Unknown fs type: %s\n" CLEAR, path);
    return -1;
  }
}