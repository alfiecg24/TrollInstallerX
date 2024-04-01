//
//  run.m
//  TrollInstallerX
//
//  Created by Alfie on 22/03/2024.
//

#import <Foundation/Foundation.h>

#import <spawn.h>
#import <sys/stat.h>


NSString* get_NSString_from_file(int fd)
{
    NSMutableString* ms = [NSMutableString new];
    ssize_t num_read;
    char c;
    if(!(fcntl(fd, F_GETFD) != -1 || errno != EBADF)) return @"";
    while((num_read = read(fd, &c, sizeof(c))))
    {
        [ms appendString:[NSString stringWithFormat:@"%c", c]];
        if(c == '\n') break;
    }
    return ms.copy;
}

// Note: spawns as current user (don't use after dropping root)
int run_binary(NSString* path, NSArray* args, NSString** output)
{
    NSMutableArray* argsM = args.mutableCopy;
    [argsM insertObject:path.lastPathComponent atIndex:0];
    
    NSUInteger argCount = [argsM count];
    char **argsC = (char **)malloc((argCount + 1) * sizeof(char*));
    
    for (NSUInteger i = 0; i < argCount; i++)
    {
        argsC[i] = strdup([[argsM objectAtIndex:i] UTF8String]);
    }
    argsC[argCount] = NULL;
    
    posix_spawn_file_actions_t action;
    posix_spawn_file_actions_init(&action);
    
    int out[2];
    pipe(out);
    posix_spawn_file_actions_adddup2(&action, out[1], STDERR_FILENO);
    posix_spawn_file_actions_addclose(&action, out[0]);
    
    pid_t task_pid;
    int status = 0;
    int spawnError = posix_spawn(&task_pid, [path UTF8String], &action, NULL, (char* const*)argsC, NULL);
    for (NSUInteger i = 0; i < argCount; i++)
    {
        free(argsC[i]);
    }
    free(argsC);
    
    if(spawnError != 0)
    {
        NSLog(@"posix_spawn error %d\n", spawnError);
        return spawnError;
    }
    
    do
    {
        if (waitpid(task_pid, &status, 0) != -1) {
        printf("Child status %d\n", WEXITSTATUS(status));
        } else
        {
            perror("waitpid");
            if(output)
            {
                *output = get_NSString_from_file(out[0]);
            }
            return -222;
        }
    } while (!WIFEXITED(status) && !WIFSIGNALED(status));
    
    close(out[1]);
    if(output)
    {
        *output = get_NSString_from_file(out[0]);
    }
    
    return WEXITSTATUS(status);
}
