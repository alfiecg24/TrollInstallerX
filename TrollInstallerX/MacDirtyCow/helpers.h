#ifndef helpers_h
#define helpers_h

char* get_temp_file_path(void);
void test_nsexpressions(void);
char* set_up_tmp_file(void);

void xpc_crasher(char* service_name);

void restartBackboard(void);
void restartFrontboard(void);



@interface LSServer : NSObject
- (BOOL)_LSPrivateRebuildApplicationDatabasesForSystemApps:(BOOL)arg1 internal:(BOOL)arg2 user:(BOOL)arg3;
@end



#define ROUND_DOWN_PAGE(val) (val & ~(PAGE_SIZE - 1ULL))

#endif /* helpers_h */
