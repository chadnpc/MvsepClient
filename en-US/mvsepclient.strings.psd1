
@{
  ModuleName    = 'mvsepclient'
  ModuleVersion = '0.1.0'
  ReleaseNotes  = @'
# Release Notes

- Version_0.1.0
- New CLI wrapper: Invoke-MvSepClient (alias: MvSepClient)
- Added static methods: New(), NewWithLogger(), GetAlgorithmsStatic(), GetQueueInfoStatic(), GetNewsStatic()
- Added CreateQualityEntry for Quality Checker feature
- Improved error handling and logging
- Supports --wait flag for automatic polling and download in CLI
- Commands: get-types, algorithms, separate, get-result, queue, news, history, premium-enable, premium-disable, long-filenames-enable, long-filenames-disable
'@
}
