################################################################################
# Time-stamp: <Thu 2017-10-05 18:49 svarrette>
#
# File::      <tt>init.pp</tt>
# Author::    UL HPC Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2017 UL HPC Team
# License::   Apache-2.0
#
# ------------------------------------------------------------------------------
# == Class: slurm
#
# The main slurm class, responsible for validating the parameters, and automate
# the provisioning and management of the daemons and compute nodes in a
# RedHat/CentOS based SLURM infrastructure.
# Slurm (A Highly Scalable Resource Manager) is an open source, fault-tolerant,
# and highly scalable cluster management and job scheduling system for large and
# small Linux clusters.
#
# More details on <https://slurm.schedmd.com/>
#
# @param ensure [String] Default: 'present'.
#         Ensure the presence (or absence) of slurm
# @param content [String]
#          The desired contents of a file, as a string. This attribute is
#          mutually exclusive with source and target.
#          See also
#          https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-content
# @param source  [String]
#          A source file, which will be copied into place on the local system.
#          This attribute is mutually exclusive with content and target.
#          See also
#          https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-source
# @param target  [String]
#          See also
#          https://docs.puppet.com/puppet/latest/types/file.html#file-attribute-target
#
############################### Main system configs #######################################
# @param uid                      [Integer]     Default: 991
# @param gid                      [Integer]     Default: as $uid
# @param version                  [String]      Default: '17.02.7'
# @param with_slurmd              [Boolean]     Default: false
# @param with_slurmctld           [Boolean]     Default: false
# @param with_slurmdbd            [Boolean]     Default: false
# @param manage_accounting        [Boolean]     Default: false
#           Whether or not this module should manage the accounting DB
# @param manage_munge             [Boolean]     Default: true
#           Whether or not this module should manage
# @param manage_pam               [Boolean]     Default: true
#           Whether or not this module should manage
# @param do_build                 [Boolean]     Default: true
#          Do we perform the build of the Slurm packages from sources or not?
# @param do_package_install       [Boolean]     Default: true
#          Do we perform the install of the Slurm packages or not?
# @param wrappers                 [Array]       Default: [ 'slurm-openlava',  'slurm-torque' ]
#          Extra wrappers/package to install (ex: openlava/LSF wrapper, Torque/PBS wrappers)
# @param src_archived             [Boolean]     Default: false
#          Whether the sources tar.bz2 has been archived or not.
#          Thus by default, it is assumed that the provided version is the
#          latest version (from https://www.schedmd.com/downloads/latest/).
#          If set to true, the sources will be download from
#             https://www.schedmd.com/downloads/archive/
# @param src_checksum             [String]      Default: ''
#           archive file checksum (match checksum_type)
# @param srcdir                   [String]      Default: '/usr/local/src'
#          Target directory for the downloaded sources
# @param builddir                 [String]      Default: '/root/rpmbuild' on redhat systems
#          Top directory of the sources builds (i.e. RPMs, debs...)
#          For instance, built RPMs will be placed under
#          ${builddir}/RPMS/${::architecture}
# @param build_with               [Array]       Default: [ 'lua', ... ]
#          see https://github.com/SchedMD/slurm/blob/master/slurm.spec
#          List of --with build options to pass to rpmbuild
# @param build_without            [Array]       Default: []
#          see https://github.com/SchedMD/slurm/blob/master/slurm.spec
#          List of --without build options to pass to rpmbuild
# @param service_manage           [Boolean]     Default: true
#          Whether to manage the slurm services.
########################                       ####################################
######################## slurm.conf attributes ####################################
########################                       ####################################
# @param configdir                [String]      Default: '/etc/slurm'
# @param clustername              [String]      Default: 'cluster'
#          The name by which this Slurm managed cluster is known in the accounting database
#
# @param acct_gatherenergytype    [String]   Default: 'none'
#          Identifies the plugin to be used for energy consumption accounting
#          Elligible values in [ 'none', 'ipmi', 'rapl' ]
# @paraù acct_storageenforce      [Array]       Default: ['qos', 'limits', 'associations']
#          What level of association-based enforcement to impose on job submissions.
# @param authtype                 [String]      Default: 'munge'
#          Elligible values in [ 'none', 'munge' ]
# @param authinfo                 [String]      Default: ''
# @param cryptotype               [String]      Default: 'munge'
#          Elligible values in [ 'munge', 'openssl']
# @param backupcontroller         [String]      Default: ''
# @param backupaddr               [String]      Default: ''
# @param controlmachine           [String]      Default: $:hostname
# @param controladdr              [String]      Default: ''
# @param batchstarttimeout        [Integer]     Default: 10
# @param checkpointtype           [String]      Default: 'none'
#          Elligible values in ['blcr', 'none', 'ompi', 'poe']
# @param completewait             [Integer]     Default: 0
# @param corespecplugin           [String]      Default: 'none'
# @param cpufreqdef               [String]      Default: undef
#          Elligible values in ['Conservative', 'OnDemand', 'Performance', 'PowerSave']
# @param cpufreqgovernors         [Array]       Default: [ 'OnDemand', 'Performance' ]
#           Elligible values in ['Conservative', 'OnDemand', 'Performance', 'PowerSave', 'UserSpace' ]
# @param debugflags               [Array]       Default: []
# @param defmempercpu             [Integer]     Default: 0
#           0 = unlimited, mutually exclusive with $defmempernode
# @param maxmempercpu             [Integer]     Default: 0
#           0 = unlimited
# @param maxmempernode            [Integer]     Default: undef
# @param defmempernode            [Integer]     Default: undef
#           0 = unlimited, mutually exclusive with $defmempercpu
# @param disablerootjobs          [Boolean]     Default: true
# @param enforcepartlimits        [String]      Default: 'ALL'
# @param epilog                   [String]      Default: ''
# @param epilogslurmctld          [String]      Default: ''
# @param fastschedule             [Integer]     Default: 1
#           Elligible values in [ 0, 1, 2]
# @param grestypes                [Array]       Default: []
#           list of generic resources to be managed
# @param healthcheckinterval      [Integer]     Default: 30
# @param healthchecknodestate     [String]      Default: 'ANY'
#           Elligible values in ['ALLOC', 'ANY','CYCLE','IDLE','MIXED']
# @param healthcheckprogram       [String]      Default: ''
# @param inactivelimit            [Integer]     Default: 0
#           0 = unlimited
# @param jobacctgathertype        [String]      Default: 'cgroup'
#           Elligible values in [ "linux", "cgroup", "none"]
# @param jobacctgatherfrequency   [Integer]     Default: 30
# @param jobacctgatherparams      [String]      Default: ''
#           Elligible values in [ 'NoShared', 'UsePss', 'NoOverMemoryKill']
# @param jobcheckpointdir         [String]      Default: ''
# @param jobcomphost              [String]      Default: ''
#            machine hosting the job completion database
# @param jobcomploc               [String]      Default: 'slurmjobs'
#           where job completion records are written (DB name, filename...)
# @param jobcomptype              [String]      Default: 'none'
#           Elligible values in ["none", "elasticsearch", "filetxt", "mysql", "script"]
# @param jobcontainertype         [String]      Default: 'none'
#           Elligible values in ['cncu', 'none'] (CNCU = Compute Node Clean Up on Cray)
# @param jobrequeue               [Boolean]     Default: true
# @param jobsubmitplugins         [Array]       Default: [ 'lua' ]
# @param killwait                 [Integer]     Default: 30
#           interval (in seconds) given to a jobs processes between the SIGTERM and SIGKILL
# @param launchtype               [String]      Default: 'slurm'
# @param licenses                 [String]      Default: ''
#           Specification of licenses
# @param maildomain               [String]      Default: $::domain
# @param mailprog                 [String]      Default: '/bin/mail'
# @param maxtaskspernode          [Integer]     Default: 512
# @param mpidefault               [String]      Default: 'none'
#           Default type of MPI to be used. Srun may override this configuration parameter in any case.
#           Elligible values in ['lam','mpich1_p4','mpich1_shmem','mpichgm','mpichmx','mvapich','none','openmpi','pmi2']
# @param mpiparams                [String]      Default: ''
#
# @param partitions               [Hash]        Default: {}
#           Hash defining the partitions and QOS settings for SLURM.
#           Format
#           { '<name>' => {
  #              nodes         => n,           # Number of nodes
  #              default       => true|false,  # Default partition?
  #              hidden        => true|false,  # Hidden partition?
  #              allowgroups   => 'ALL|group[,group]*'
  #              allowaccounts => 'ALL|acct[,acct]*'
  #              allowqos      => 'ALL|qos[,qos]*'
  #              state         => 'UP|DOWN|DRAIN|INACTIVE'
  #              oversubscribe => 'EXCLUSIVE|FORCE|YES|NO' (replace :shared)
  #              #=== Time: Format is minutes, minutes:seconds, hours:minutes:seconds, days-hours,
  #                      days-hours:minutes, days-hours:minutes:seconds or "UNLIMITED"
  #              default_time  => 'UNLIMITED|DD-HH:MM:SS',
  #              max_time      => 'UNLIMITED|DD-HH:MM:SS',
  #              #=== associated QoS config, named 'qos-<partition>' ===
  #              priority      => n           # QoS priority (default: 0)
  #              preempt       => 'qos-<name>
  #         }
# @param preemptmode              [Array]       Default: [ 'REQUEUE' ]
#           in ['OFF','CANCEL','CHECKPOINT','GANG','REQUEUE','SUSPEND']
# @param preempttype              [String]      Default: 'qos'
#           in ['none', 'partition_prio', 'qos']
# @param prioritydecayhalflife    [String]      Default: '5-0'
#           aka 5 days
# @param priorityflags            [Array]       Default: []
# @param prioritytype             [String]      Default: 'multifactor'
#           Elligible values in ['basic', 'multifactor']
# @param priorityweightage        [Integer]     Default: 0
# @param priorityweightfairshare  [Integer]     Default: 0
# @param priorityweightjobsize    [Integer]     Default: 0
# @param priorityweightpartition  [Integer]     Default: 0
# @param priorityweightqos        [Integer]     Default: 0
# @param privatedata              [Array]       Default: []
#           Elligible values in ['accounts','cloud','jobs','nodes','partitions','reservations','usage','users']
# @param proctracktype            [String]      Default: 'cgroup'
#           Elligible values in ['cgroup', 'cray', 'linuxproc', 'lua', 'sgi_job','pgid']

# @param prolog                   [String]      Default: ''
# @param prologflags              [Array]       Default: []
# @param prologslurmctld          [String]      Default: ''
# @param propagateresourcelimits  [Array]       Default: []
# @param propagateresourcelimits_except [Array] Default: ['MEMLOCK']

# @param returntoservice          [Integer]     Default: 1
#           Elligible values in [0, 1, 2]
# @param statesavelocation        [String]      Default: '/var/lib/slurmctld'
#           Fully qualified pathname of a directory into which the Slurm
#           controller, slurmctld, saves its state
# @param schedulertype            [String ]     Default: 'backfill'
#           Elligible values in ['backfill', 'builtin', 'hold']
# @param selecttype               [String ]     Default: 'cons_res'
#           Elligible values in ['bluegene','cons_res','cray','linear','serial' ]
# @param selecttype_params        [Array  ]     Default: [ 'CR_Core_Memory', 'CR_CORE_DEFAULT_DIST_BLOCK' ]

# @param slurmctlddebug           [String ]     Default: 'info'
# @param slurmddebug              [String ]     Default: 'info'

# @param slurmctldport            [Integer]     Default: 6817
# @param slurmdport               [Integer]     Default: 6818
# @param srunportrange            [String ]     Default: '50000-53000'
# @param srunepilog               [String ]     Default: ''
# @param srunprolog               [String ]     Default: ''
# @param switchtype               [String ]     Default: 'none'
#           Elligible values in ['nrt', 'none']
# @param taskepilog               [String ]     Default: ''
# @param taskplugin               [String ]     Default: 'cgroup'
#           Elligible values in ['affinity', 'cgroup','none']
# @param taskpluginparams         [Array  ]     Default: ['cpusets']
# @param taskprolog               [String ]     Default: ''
# @param tmpfs                    [String ]     Default: '/tmp'
# @param waittime                 [Integer]     Default: 0
#
############################                          ####################################
############################ topology.conf attributes ####################################
############################                          ####################################
#
# @param topology                 [String ]     Default:  = none
#           Which topology plugin to be used for determining the network topology and
#           optimizing job allocations to minimize network contention
#           Elligible values
#             3d_torus  -- best-fit logic over three-dimensional topology
#             node_rank -- orders nodes based upon information a node_rank field in the
#                 node record as generated by a select plugin. Slurm performs a best-fit
#                 algorithm over those ordered nodes
#             none -- default for other systems, best-fit logic over one-dimensional topology
#             tree -- used for a hierarchical network as described in a topology.conf file
# @param topology_content         [String]      Default: undef
#           The desired contents of a topology file, as a string. This attribute is
#           mutually exclusive with topology_source and topology_target.
# @param topology_source          [String]      Default: undef
#          A source topology file, which will be copied into place on the local system.
#          This attribute is mutually exclusive with topology_{content,target}.
# @param topology_target          [String]      Default: undef
#          Target link path
# @param topology_tree            [Hash]     Default:  {}
#          Hash defining the hierarchical network topology iff $topology == 'tree'
#          Format
#          'switchname' => {
  #              [comment => 'This will become a comment above the line',]
  #              nodes => '<nodes>',
  #              [linkspeed => '<speed>']
  #        }
#        Example
#        { 's0' => { nodes => 'dev[0-5]'   },
#          's1' => { nodes => 'dev-[6-11]' },
#          's2' => { nodes => 'dev-[12-17]'},
#          's3' => { comment   => 'GUID: XXXXXX - switch 0',
  #                  switches  => 's[0-2]',
  #                  linkspeed => '100Mb/s',} }
#       Which will produce the following entries in the topology.conf file
#           SwitchName=s0 Nodes=dev[0-5]
#           SwitchName=s1 Nodes=dev-[6-11]
#           SwitchName=s2 Nodes=dev-[12-17]
#           # GUID: XXXXXX - switch 0
#           SwitchName=s3 Switches=s[0-2] LinkSpeed=100Mb/s
#
############################                        ####################################
############################ cgroup.conf attributes ####################################
############################                        ####################################
#
# @param cgroup_content           [String]      Default: undef
#           The desired contents of a cgroup file, as a string. This attribute is
#           mutually exclusive with cgroup_source and cgroup_target.
# @param cgroup_source            [String]      Default: undef
#          A source cgroup file, which will be copied into place on the local system.
#          This attribute is mutually exclusive with cgroup_{content,target}.
# @param cgroup_target            [String]      Default: undef
#          Target link path
# @param cgroup_automount          [Boolean]    Default: true
# @param cgroup_mountpoint         [String]     Default: '/sys/fs/cgroup'
# @param cgroup_alloweddevices     [Array]      Default: []
#           if non-empty, cgroup_allowed_devices_file.conf will host the list of
#           devices that need to be allowed by default for all the jobs
# @param cgroup_allowedkmemspace   [String]     Default: undef
#           amount of the allocated kernel memory
# @param cgroup_allowedramspace    [Numeric]    Default: 100
#           percentage of the allocated memory
# @param cgroup_allowedswapspace   [Numeric]    Default: 0
#           percentage of the swap space
# @param cgroup_constraincores     [Boolean]    Default: true
# @param cgroup_constraindevices   [Boolean]    Default: false
#          constrain the job's allowed devices based on GRES allocated resources.
# @param cgroup_constrainkmemspace [Boolean]    Default: true
# @param cgroup_constrainramspace  [Boolean]    Default: true
# @param cgroup_constrainswapspace [Boolean]    Default: true
# @param cgroup_maxrampercent      [Numeric]    Default: 100
#            upper bound in percent of total RAM on the RAM constraint for a job.
# @param cgroup_maxswappercent     [Numeric]    Default: 100
#            upper bound (in percent of total RAM) on the amount of RAM+Swap
# @param cgroup_maxkmempercent     [Numeric]    Default: 100
#            upper bound in percent of total Kmem for a job.
# @param cgroup_minkmemspace       [String]     Default: '30M'
#            lower bound (in MB) on the memory limits defined by AllowedKmemSpace.
# @param cgroup_minramspace        [String]     Default: '30M'
#            lower bound (in MB) on the memory limits defined by AllowedRAMSpace & AllowedSwapSpace.
# @param cgroup_taskaffinity       [Boolean]    Default: true
#            This feature requires the Portable Hardware Locality (hwloc) library
#
############################                      ####################################
############################ gres.conf attributes ####################################
############################                      ####################################
#
# @param gres_content              [String]      Default: undef
#           The desired contents of a Generic Resource (GRES) configuration file, as a string.
#           This attribute is  mutually exclusive with gres_source and gres_target.
# @param gres_source               [String]      Default: undef
#          A source GRES file, which will be copied into place on the local system.
#          This attribute is mutually exclusive with gres_{content,target}.
# @param gres_target               [String]      Default: undef
#          Target link path
# @param gres                 [Hash]     Default:  {}
#          Hash defining the generic resource management entries
#          Format
#          '<nodename>' => {
  #              [comment => 'This will become a comment above the line',]
  #              name => '<name>',
  #              file => '<file>'
  #              [...]
  #        }
#
############################                      ####################################
############################ MUNGE Authentication ####################################
############################                      ####################################
# @param munge_create_key          [Boolean]       Default: true
#          Whether or not to generate a new key if it does not exists
# @param munge_daemon_args         [Array] Default: []
#          Set the content of the DAEMON_ARGS variable, which permits to set
#          additional command-line options to the daemon. For example, this can
#          be used to override the location of the secret key (--key-file) or
#          set the number of worker threads (--num-threads) See
#          https://github.com/dun/munge/wiki/Installation-Guide#starting-the-daemon
# @param munge_gid [Integer] Default: 992
#          GID of the munge group
# @param munge_key_content         [String]       Default: undef
#          The desired contents of a file, as a string. This attribute is mutually
#          exclusive with source and target.
# @param munge_key_filename        [String]       Default: '/etc/munge/munge.key'
#          The secret key filename
# @param munge_key_source          [String]       Default: undef
#          A source file, which will be copied into place on the local system.
#          This attribute is mutually exclusive with content.
#          The normal form of a puppet: URI is
#                  puppet:///modules/<MODULE NAME>/<FILE PATH>
# @param munge_uid                 [Integer]      Default: 992
#          UID of the munge user
#
############################              ####################################
############################ PAM Settings ####################################
############################              ####################################
# @param use_pam                  [Boolean]       Default: true
#
###
### SPANK - Slurm Plug-in Architecture for Node and job (K)control
### See <https://slurm.schedmd.com/spank.html>
###
# @param pluginsdir_target          [String] Default: undef,
#          If definied, symlink target base directory for all plugins
#          <plugin>.conf _i.e._ <configdir>/plugstack.conf.d/<plugin>.conf
#          points to <pluginsdir_target>/<plugin>.conf
# @param plugins                    [Array] Default: []
#          List of plugins to see in <configdir>/plugstack.conf.d/

#
# @example Default instance
#
#     include '::slurm'
#
# You can then specialize the various aspects of the configuration,
# for instance
#
#         class { 'slurm':
  #             ensure => 'present'
  #         }
#
# === Authors
#
# The UL HPC Team <hpc-sysadmins@uni.lu> of the University of Luxembourg, in
# particular
# * Sebastien Varrette <Sebastien.Varrette@uni.lu>
# * Valentin Plugaru   <Valentin.Plugaru@uni.lu>
# * Sarah Peter        <Sarah.Peter@uni.lu>
# * Hyacinthe Cartiaux <Hyacinthe.Cartiaux@uni.lu>
# * Clement Parisot    <Clement.Parisot@uni.lu>
#
# === Warnings
#
# /!\ Always respect the style guide available here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
class slurm(
  String  $ensure                         = $slurm::params::ensure,
  $content                                = undef,
  $source                                 = undef,
  $target                                 = undef,
  Boolean $manage_accounting              = $slurm::params::manage_accounting,
  Boolean $manage_firewall                = $slurm::params::manage_firewall,
  Boolean $manage_munge                   = $slurm::params::manage_munge,
  Boolean $manage_pam                     = $slurm::params::manage_pam,
  Boolean $service_manage                 = $slurm::params::service_manage,
  Integer $uid                            = $slurm::params::uid,
  Integer $gid                            = $slurm::params::gid,
  String  $version                        = $slurm::params::version,
  Boolean $with_slurmd                    = $slurm::params::with_slurmd,
  Boolean $with_slurmctld                 = $slurm::params::with_slurmctld,
  Boolean $with_slurmdbd                  = $slurm::params::with_slurmdbd,
  Array   $wrappers                       = $slurm::params::wrappers,
  # Slurm source building
  Boolean $do_build                       = $slurm::params::do_build,
  Boolean $do_package_install             = $slurm::params::do_package_install,
  Boolean $src_archived                   = $slurm::params::src_archived,
  String  $src_checksum                   = $slurm::params::src_checksum,
  String  $srcdir                         = $slurm::params::srcdir,
  String  $builddir                       = $slurm::params::builddir,
  Array   $build_with                     = $slurm::params::build_with,
  Array   $build_without                  = $slurm::params::build_without,
  #
  # Main configuration paramaters
  #
  Array   $acct_storageenforce            = $slurm::params::acct_storageenforce,
  String  $acct_gatherenergytype          = $slurm::params::acct_gatherenergytype,
  String  $configdir                      = $slurm::params::configdir,
  String  $clustername                    = $slurm::params::clustername,
  String  $authtype                       = $slurm::params::authtype,
  String  $authinfo                       = $slurm::params::authinfo,
  String  $cryptotype                     = $slurm::params::cryptotype,
  String  $backupcontroller               = $slurm::params::backupcontroller,
  String  $backupaddr                     = $slurm::params::backupaddr,
  String  $controlmachine                 = $slurm::params::controlmachine,
  String  $controladdr                    = $slurm::params::controladdr,
  #
  Integer $batchstarttimeout              = $slurm::params::batchstarttimeout,
  String  $checkpointtype                 = $slurm::params::checkpointtype,
  Integer $completewait                   = $slurm::params::completewait,
  String  $corespecplugin                 = $slurm::params::corespecplugin,
  $cpufreqdef                             = $slurm::params::cpufreqdef,
  Array   $cpufreqgovernors               = $slurm::params::cpufreqgovernors,
  Array   $debugflags                     = $slurm::params::debugflags,
  #
  Integer $defmempercpu                   = $slurm::params::defmempercpu,
  Integer $maxmempercpu                   = $slurm::params::maxmempercpu,
  $maxmempernode                          = $slurm::params::maxmempernode,
  $defmempernode                          = $slurm::params::defmempernode,
  #
  Boolean $disablerootjobs                = $slurm::params::disablerootjobs,
  String  $enforcepartlimits              = $slurm::params::enforcepartlimits,
  String  $epilog                         = $slurm::params::epilog,
  String  $epilogslurmctld                = $slurm::params::epilogslurmctld,
  Integer $fastschedule                   = $slurm::params::fastschedule,
  Integer $getenvtimeout                  = $slurm::params::getenvtimeout,
  Array   $grestypes                      = $slurm::params::grestypes,
  Integer $healthcheckinterval            = $slurm::params::healthcheckinterval,
  String  $healthchecknodestate           = $slurm::params::healthchecknodestate,
  String  $healthcheckprogram             = $slurm::params::healthcheckprogram,
  Integer $inactivelimit                  = $slurm::params::inactivelimit,
  String  $jobacctgathertype              = $slurm::params::jobacctgathertype,
  Integer $jobacctgatherfrequency         = $slurm::params::jobacctgatherfrequency,
  String  $jobacctgatherparams            = $slurm::params::jobacctgatherparams,
  String  $jobcheckpointdir               = $slurm::params::jobcheckpointdir,
  String  $jobcomphost                    = $slurm::params::jobcomphost,
  String  $jobcomploc                     = $slurm::params::jobcomploc,
  String  $jobcomptype                    = $slurm::params::jobcomptype,
  String  $jobcontainertype               = $slurm::params::jobcontainertype,
  Boolean $jobrequeue                     = $slurm::params::jobrequeue,
  Array   $jobsubmitplugins               = $slurm::params::jobsubmitplugins,
  Integer $killwait                       = $slurm::params::killwait,
  String  $launchtype                     = $slurm::params::launchtype,
  String  $licenses                       = $slurm::params::licenses,
  String  $maildomain                     = $slurm::params::maildomain,
  String  $mailprog                       = $slurm::params::mailprog,
  Integer $maxtaskspernode                = $slurm::params::maxtaskspernode,
  Integer $messagetimeout                 = $slurm::params::messagetimeout,
  # Default type of MPI to be used.
  String  $mpidefault                     = $slurm::params::mpidefault,
  String  $mpiparams                      = $slurm::params::mpiparams,
  # Nodes definition
  Hash    $nodes                          = $slurm::params::nodes,
  # Partitons / QOS
  Hash    $partitions                     = $slurm::params::partitions,
  Array   $preemptmode                    = $slurm::params::preemptmode,
  String  $preempttype                    = $slurm::params::preempttype,
  String  $prioritydecayhalflife          = $slurm::params::prioritydecayhalflife,
  Array   $priorityflags                  = $slurm::params::priorityflags,
  String  $prioritytype                   = $slurm::params::prioritytype,
  Integer $priorityweightage              = $slurm::params::priorityweightage,
  Integer $priorityweightfairshare        = $slurm::params::priorityweightfairshare,
  Integer $priorityweightjobsize          = $slurm::params::priorityweightjobsize,
  Integer $priorityweightpartition        = $slurm::params::priorityweightpartition,
  Integer $priorityweightqos              = $slurm::params::priorityweightqos,
  Array   $privatedata                    = $slurm::params::privatedata,
  String  $proctracktype                  = $slurm::params::proctracktype,
  #
  String  $prolog                         = $slurm::params::prolog,
  Array   $prologflags                    = $slurm::params::prologflags,
  String  $prologslurmctld                = $slurm::params::prologslurmctld,
  Array   $propagateresourcelimits        = $slurm::params::propagateresourcelimits,
  Array   $propagateresourcelimits_except = $slurm::params::propagateresourcelimits_except,
  Hash    $qos                            = $slurm::params::qos,
  Integer $resumetimeout                  = $slurm::params::resumetimeout,
  Integer $returntoservice                = $slurm::params::returntoservice,
  String  $statesavelocation              = $slurm::params::statesavelocation,
  String  $schedulertype                  = $slurm::params::schedulertype,
  String  $selecttype                     = $slurm::params::selecttype,
  Array   $selecttype_params              = $slurm::params::selecttype_params,
  # Log details
  String  $slurmctlddebug                 = $slurm::params::slurmctlddebug,
  String  $slurmddebug                    = $slurm::params::slurmddebug,
  # Ports
  Integer $slurmctldport                  = $slurm::params::slurmctldport,
  Integer $slurmdport                     = $slurm::params::slurmdport,
  String  $srunportrange                  = $slurm::params::srunportrange,
  String  $srunepilog                     = $slurm::params::srunepilog,
  String  $srunprolog                     = $slurm::params::srunprolog,
  String  $switchtype                     = $slurm::params::switchtype,
  String  $taskepilog                     = $slurm::params::taskepilog,
  String  $taskplugin                     = $slurm::params::taskplugin,
  Array   $taskpluginparams               = $slurm::params::taskpluginparams,
  String  $taskprolog                     = $slurm::params::taskprolog,
  String  $tmpfs                          = $slurm::params::tmpfs,
  Integer $waittime                       = $slurm::params::waittime,
  #
  # Which topology plugin to be used for determining the network topology and
  # optimizing job allocations to minimize network contention
  # see topology.conf in case $topology  == 'tree'
  #
  String  $topology                       = $slurm::params::topology,
  $topology_content                       = undef,
  $topology_source                        = undef,
  $topology_target                        = undef,
  Hash    $topology_tree                  = {},
  #
  # job_submit.lua
  #
  $lua_content                            = undef,
  $lua_source                             = undef,
  $lua_target                             = undef,
  #
  # cgroup.conf
  #
  $cgroup_content                         = undef,
  $cgroup_source                          = undef,
  $cgroup_target                          = undef,
  Boolean $cgroup_automount               = $slurm::params::cgroup_automount,
  String  $cgroup_mountpoint              = $slurm::params::cgroup_mountpoint,
  Array   $cgroup_alloweddevices          = $slurm::params::cgroup_alloweddevices,
  $cgroup_allowedkmemspace                = $slurm::params::cgroup_allowedkmemspace,
  Numeric $cgroup_allowedramspace         = $slurm::params::cgroup_allowedramspace,
  Numeric $cgroup_allowedswapspace        = $slurm::params::cgroup_allowedswapspace,
  Boolean $cgroup_constraincores          = $slurm::params::cgroup_constraincores,
  Boolean $cgroup_constraindevices        = $slurm::params::cgroup_constraindevices,
  Boolean $cgroup_constrainkmemspace      = $slurm::params::cgroup_constrainkmemspace,
  Boolean $cgroup_constrainramspace       = $slurm::params::cgroup_constrainramspace,
  Boolean $cgroup_constrainswapspace      = $slurm::params::cgroup_constrainswapspace,
  Numeric $cgroup_maxrampercent           = $slurm::params::cgroup_maxrampercent,
  Numeric $cgroup_maxswappercent          = $slurm::params::cgroup_maxswappercent,
  Numeric $cgroup_maxkmempercent          = $slurm::params::cgroup_maxkmempercent,
  Integer $cgroup_minkmemspace            = $slurm::params::cgroup_minkmemspace,
  Integer $cgroup_minramspace             = $slurm::params::cgroup_minramspace,
  Boolean $cgroup_taskaffinity            = $slurm::params::cgroup_taskaffinity,
  #
  # gres.conf
  #
  $gres_content                           = undef,
  $gres_source                            = undef,
  $gres_target                            = undef,
  Hash    $gres                           = {},
  #
  # Munge authentication service
  #
  Boolean $munge_create_key               = $slurm::params::munge_create_key,
  Array   $munge_daemon_args              = $slurm::params::munge_daemon_args,
  $munge_key_source                       = undef,
  $munge_key_content                      = undef,
  String  $munge_key_filename             = $slurm::params::munge_key,
  Integer $munge_uid                      = $slurm::params::munge_uid,
  Integer $munge_gid                      = $slurm::params::munge_gid,
  #
  # PAM settings
  #
  Boolean $use_pam                        = $slurm::params::use_pam,
  # Array   $pam_allowed_users              = $slurm::params::pam_allowed_users,
  # String  $pam_content                    = $slurm::params::pam_content,
  # String  $pam_limits_source              = $slurm::params::pam_limits_source,
  # Boolean $use_pam_slurm_adopt            = $slurm::params::use_pam_slurm_adopt,
  #
  # SPANK - Slurm Plug-in Architecture for Node and job (K)control
  # See <https://slurm.schedmd.com/spank.html>
  #
  $pluginsdir_target                      = undef,
  Array $plugins                          = [],
)
inherits slurm::params
{
  validate_legacy('String', 'validate_re', $ensure, ['^present', '^absent'])

  info ("Configuring SLURM (with ensure = ${ensure})")

  case $::osfamily {
    #'Debian': { contain ::slurm::common::debian }
    'RedHat':  { contain ::slurm::common::redhat }
    default: {
      fail("Module ${module_name} is not supported on ${::operatingsystem}")
    }
  }
}
