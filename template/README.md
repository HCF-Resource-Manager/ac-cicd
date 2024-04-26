# template
## This is designed to be run in a folder inside jobs, as the user jenkins:jenkins

### Definitions:
<li>Default folder: Using default settings, the target would be /var/lib/jenkins/jobs
<ul><li>This is where the pipeline sub-folders exist with config.xml</li></ul></li>

<li><b>pipespread.sh</b>: This loaded data from pipelines to create a text file</li>

<li><b>list_of_pipes.txt</b>: A file with pipelineid space EC#</li>

<li><b>template.xml</b>: A file with a replacement config.xml with {{1}} and {{2}} where EC and pipe names need to go.
<ul><li><b>update_pipes.sh</b>: Script that takes the list file (list_of_pipes.txt), for each line:
<li>move config.xml to config.back.backupid
<li>copy the new template file to, to config.xml in that folder, replacing {{1}} and {{2}} as appropriate</ul>
</li>
